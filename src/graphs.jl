
const IntPair = Tuple{Int,Int}

struct Edge
    s::Int      # source index
    t::Int      # target index
    k::Int      # kind index
end


"""
Tree graph.
"""
mutable struct Tree
    nv::Int                             # number of vertices
    nt::Int                             # number of edge types
    root::Int                           # the root vertex
    parents::Vector{Int}                # parent vertices
    parents_lt::Vector{Int}             # parent-link types
    children::Vector{Vector{Int}}       # children vertices
    children_lt::Vector{Vector{Int}}    # children-link types

    function Tree(nv::Int, nt::Int,
                  parents::Vector{Int}, parents_lt::Vector{Int})

        @assert length(parents) == length(parents_lt) == nv

        children = [Int[] for _ = 1:nv]
        children_lt = [Int[] for _ = 1:nv]
        root = 0
        for v = 1:nv
            p = parents[v]
            if p == v   # is-root
                @assert root == 0
                root = v
            else        # non-root
                push!(children[p], v)
                push!(children_lt[p], -parents_lt[v])
            end
        end
        @assert root > 0
        @assert(sum(length(a) for a in children) == nv-1)

        new(nv, nt, root, parents, parents_lt, children, children_lt)
    end
end

nvertices(g::Tree) = g.nv
nedgetypes(g::Tree) = g.nt
nedges(g::Tree) = g.nv - 1

parent(g::Tree, v::Int) = g.parents[v]
parent_linktype(g::Tree, v::Int) = g.parents_lt[v]
children(g::Tree, v::Int) = g.children[v]
children_linktypes(g::Tree, v::Int) = g.children_lt[v]
degree(g::Tree, v::Int) = Int(g.root != v) + length(g.children[v])

root(g::Tree) = g.root
isroot(g::Tree, v::Int) = (g.root == v)
isleaf(g::Tree, v::Int) = isempty(children(g, v))


"""
Undirected graph.
"""
mutable struct UGraph
    nv::Int     # number of vertices
    nk::Int     # number of edge kinds

    # edge list (grouped by kind)
    elst::Vector{Edge}
    elst_offs::Vector{Int}

    # concatenated list of incoming edge indices (grouped by vertices)
    ies::Vector{Int}
    ies_offs::Vector{Int}

    # concatenated list of outgoing edge indices (grouped by vertices)
    oes::Vector{Int}
    oes_offs::Vector{Int}
end


"""
Construct an undirected graph based on a grouped edge list.
"""
function UGraph(nv::Int, nk::Int, elst::Vector{Edge}, elst_offs::Vector{Int})
    @assert length(elst_offs) == nk + 1

    # prepare storage
    ne = length(elst)
    ies = Vector{Int}(ne)
    ies_offs = Vector{Int}(nv + 1)
    oes = Vector{Int}(ne)
    oes_offs = Vector{Int}(nv + 1)

    icnt = zeros(Int, nv)
    ocnt = zeros(Int, nv)

    # scan edges & store counts to icnt & ocnt
    for e in elst:
        0 <= e.s < nv || throw(BoundsError("Vertex index out of range."))
        0 <= e.t < nv || throw(BoundsError("Vertex index ouf of range."))
        icnt[e.t] += 1
        ocnt[e.s] += 1
    end

    # compute section offsets
    ies_offs[1] = oes_offs[1] = 0
    cumsum!(view(ies_offs, 2:nv+1), icnt)
    cumsum!(view(oes_offs, 2:nv+1), ocnt)
    @assert ies_offs[nv + 1] == ne
    @assert oes_offs[nv + 1] == ne

    # fill in edge indices
    fill!(icnt, 0)
    fill!(ocnt, 0)
    for (i, e) in enumerate(elst)
        i_off = icnt[e.t]; icnt[e.t] += 1
        o_off = ocnt[e.s]; ocnt[e.s] += 1
        ies[1 + i_off] = i
        oes[1 + o_off] = i
    end

    # construct & return
    return UGraph(nv, nk, elst, elst_offs, ies, ies_offs, oes, oes_offs)
end


"""
Construct an undirected graph with a list of edges (in vertex pairs).

# Arguments

- nv:       The number of vertices
- edges:    The list of edges. Each element in a vertex pair.

# Keyword arguments

- shared_kind:   Whether all edges share the same kind. (default = `false`)
                 When `true`, all edges share the same kind index `1`.
                 When `false`, the `i`-th edge has the kind index `i`.
"""
function UGraph(nv::Int, edges::AbstractVector{IntPair}; shared_kind::Bool=false)
    nv >= 0 || throw(ArgumentError("nv must be non-negative."))

    # make edge list
    ne = len(edges)
    nk = (shared_kind ? 1 : ne)

    elst = Vector{Edge}(ne)
    elst_offs = Vector{Int}(nk + 1)
    if shared_kind
        for (i, e) in enumerate(edges)
            elst[i] = Edge(e[0], e[1], 1)
        end
        elst_offs[1] = 0
        elst_offs[2] = ne
    else
        for (i, e) in enumerate(edges)
            elst[i] = Edge(e[0], e[1], i)
            elst_offs[i] = i
        end
        elst_offs[nk + 1] = ne
    end

    # construct
    return UGraph(nv, nk, elst, elst_offs)
end


"""
Construct an undirected graph (with edges grouped by kinds).

# Arguments

- nv:      The number of vertices.
- egrps:   A list of edge groups. ``gedges[k]`` is the list of edges for
           the `k`-th kind.
"""
function UGraph{G}(nv::Int, egrps::AbstractVector{G}) where G<:AbstractVector{IntPair}
    nv >= 0 || throw(ArgumentError("nv must be non-negative."))

    # make edge list
    nk = length(egrps)
    ne = sum(length(g) for g in gedges)
    elst = Vector{Edge}(ne)
    elst_offs = Vector{Int}(nk + 1)
    i = 0
    elst_offs[1] = 0
    for (k, g) in enumerate(egrps)
        for e in g
            elst[i += 1] = Edge(e[0], e[1], k)
        end
        elst_offs[k + 1] = elst_offs[k] + length(g)
    end
    @assert i == ne
    @assert elst_offs[nk + 1] == ne

    # construct
    return UGraph(nv, nk, elst, elst_offs)
end


nvertices(g::UGraph) = g.nv
nedgekinds(g::UGraph) = g.nk
nedges(g::UGraph) = length(g.elst)

vertices(g::UGraph) = 1:g.nv
edges(g::UGraph) = g.elst

degree_of(g::UGraph, v::Int) = g.elst_offs[v + 1] - g.elst_offs[v]


edges(g::UGraph, t::Int) = g.tlst[t]
degree(g::UGraph, v::Int) = length(g.nbs[v])
neighbors(g::UGraph, v::Int) = g.nbs[v]
neighbor_linktypes(g::UGraph, v::Int) = g.nbs_lt[v]


"""
Convert a tree-structured undirected graph to an instance of Tree.

# Arguments
- g:  The input graph.
- r:  The index of the root.

It throws an ArgumentError if `g` is not a connected tree.
"""
function to_tree(g::UGraph, r::Int)
    nv = nvertices(g)
    0 < r <= nv || throw(BoundsError("Root index out of range."))
    nedges(g) == nv - 1 || throw(
        BoundsError("Unexpected number of edges for a tree."))

    parents = collect(1:nv)
    parents_lt = zeros(Int, nv)
    visited = fill(false, nv)

    # initialize the queue of active vertices
    que = zeros(Int, nv)
    que[1] = r
    qf = 0
    qr = 1
    visited[r] = true

    # main loop
    while qf < qr       # non-empty queue
        u = que[qf += 1]
        p = parents[u]
        for (v, t) in zip(neighbors(g, u), neighbor_linktypes(g, u))
            if v != p
                if visited[v]
                    throw(ArgumentError("A cycle through $v is detected."))
                end
                # tag v as visited, and store its parent
                visited[v] = true
                parents[v] = u
                parents_lt[v] = -t
                # enqueue v as an active vertex
                que[qr+=1] = v
            end
        end
    end

    if qr < nv
        throw(ArgumentError("The input graph has disjoint components."))
    end
    Tree(nv, nedgetypes(g), parents, parents_lt)
end
