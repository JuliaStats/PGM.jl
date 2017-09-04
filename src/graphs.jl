
const IntPair = Tuple{Int,Int}

"""
Edge with a kind index.

Each instance of ``Edge`` has three fields:

- ``s``:  index of the source vertex.
- ``t``:  index of the target vertex.
- ``k``:  the kind index, which can be used to access external data.
"""
struct Edge
    s::Int      # source index
    t::Int      # target index
    k::Int      # kind index

    Edge(s::Int, t::Int, k::Int) = new(s, t, k)
    Edge(e::IntPair, k::Int) = new(e[1], e[2], k)
end

"""
Undirected graph.
"""
mutable struct UGraph
    nv::Int     # number of vertices
    g_elst::GroupedList{Edge}   # edge list (grouped by kind)
    g_ies::GroupedList{Int}     # incoming edge indices (grouped by vertices)
    g_oes::GroupedList{Int}     # outgoing edge indices (grouped by vertices)

    function UGraph(nv::Int, nk::Int, g_elst::GroupedList)
        ne = length(g_elst)
        g_ies = grlist_by(1:ne, nv, i->g_elst[i].t)
        g_oes = grlist_by(1:ne, nv, i->g_elst[i].s)
        new(nv, g_elst, g_ies, g_oes)
    end
end

nvertices(g::UGraph) = g.nv
nedgekinds(g::UGraph) = ngroups(g.g_elst)
nedges(g::UGraph) = length(g.g_elst)

vertices(g::UGraph) = 1:g.nv
edges(g::UGraph) = g.g_elst.elems
edges_of(g::UGraph, k::Int) = group(g.g_elst, k)

indegree_at(g::UGraph, v::Int) = group_length(g.g_ies, v)
outdegree_at(g::UGraph, v::Int) = group_length(g.g_oes, v)
degree_at(g::UGraph, v::Int) = indegree_at(g, v) + outdegree_at(g, v)

inedges_at(g::UGraph, v::Int) = view(edges(g), group(g.g_ies, v))
outedges_at(g::UGraph, v::Int) = view(edges(g), group(g.g_oes, v))


"""
Construct an undirected graph with a list of edges (in vertex pairs).

# Arguments

- ``nv``:       The number of vertices
- ``edges``:    The list of edges. Each element in a vertex pair.

# Keyword arguments

- ``shared_kind``:   Whether all edges share the same kind (default = `false`).
                     When `true`, all edges share the same kind index `1`;
                     otherwise, they are assumed to have different kinds,
                     *i.e.*, the kind index of the  `i`-th edge is `i`.
"""
function UGraph(nv::Int, edges::AbstractVector{IntPair}; shared_kind::Bool=false)
    nv >= 0 || throw(ArgumentError("nv must be non-negative."))

    # make edge list
    ne = length(edges)
    nk = (shared_kind ? 1 : ne)

    elst = Vector{Edge}(ne)
    elst_cnts = Vector{Int}(nk)
    if shared_kind
        for (i, e) in enumerate(edges)
            elst[i] = Edge(e, 1)
        end
        elst_cnts[1] = ne
    else
        for (i, e) in enumerate(edges)
            elst[i] = Edge(e, i)
            elst_cnts[i] = 1
        end
    end
    g_elst = grlist_from_counts(elst, elst_cnts)

    # construct
    UGraph(nv, nk, g_elst)
end


"""
Construct an undirected graph with edges grouped by their kinds.

# Arguments

- nv:      The number of vertices.
- egrps:   A list of edge groups. `gedges[k]` is the list of edges for
           the `k`-th kind.
"""
function UGraph{G<:AbstractVector{IntPair}}(nv::Int, egrps::AbstractVector{G})
    nv >= 0 || throw(ArgumentError("nv must be non-negative."))

    # make edge list
    nk = length(egrps)
    ne = sum(length(g) for g in egrps)
    elst = Vector{Edge}(ne)
    elst_cnts = Vector{Int}(nk)

    i = 0
    for (k, g) in enumerate(egrps)
        for e in g
            elst[i += 1] = Edge(e, k)
        end
        elst_cnts[k] = length(g)
    end
    @assert i == ne
    g_elst = grlist_from_counts(elst, elst_cnts)

    # construct
    UGraph(nv, nk, g_elst)
end


# """
# Convert a tree-structured undirected graph to an instance of Tree.
#
# # Arguments
# - g:  The input graph.
# - r:  The index of the root.
#
# It throws an ArgumentError if `g` is not a connected tree.
# """
# function to_tree(g::UGraph, r::Int)
#     nv = nvertices(g)
#     0 < r <= nv || throw(BoundsError("Root index out of range."))
#     nedges(g) == nv - 1 || throw(
#         BoundsError("Unexpected number of edges for a tree."))
#
#     parents = collect(1:nv)
#     parents_lt = zeros(Int, nv)
#     visited = fill(false, nv)
#
#     # initialize the queue of active vertices
#     que = zeros(Int, nv)
#     que[1] = r
#     qf = 0
#     qr = 1
#     visited[r] = true
#
#     # main loop
#     while qf < qr       # non-empty queue
#         u = que[qf += 1]
#         p = parents[u]
#         for (v, t) in zip(neighbors(g, u), neighbor_linktypes(g, u))
#             if v != p
#                 if visited[v]
#                     throw(ArgumentError("A cycle through $v is detected."))
#                 end
#                 # tag v as visited, and store its parent
#                 visited[v] = true
#                 parents[v] = u
#                 parents_lt[v] = -t
#                 # enqueue v as an active vertex
#                 que[qr+=1] = v
#             end
#         end
#     end
#
#     if qr < nv
#         throw(ArgumentError("The input graph has disjoint components."))
#     end
#     Tree(nv, nedgetypes(g), parents, parents_lt)
# end
