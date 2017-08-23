
const IntPair = Tuple{Int,Int}


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
    ne::Int     # number of undirected edges
    nt::Int     # number of edge types

    # lists of neighbors for each vertex
    nbs::Vector{Vector{Int}}

    # lists of neighbor (signed) link-types for each vertex
    nbs_lt::Vector{Vector{Int}}

    # collected typed edge list
    # each entry is a list of edges of the corresponding type
    tlst::Vector{Vector{IntPair}}

    function UGraph(nv::Int, ne::Int, nt::Int,
                    nbs::Vector{Vector{Int}},
                    nbs_lt::Vector{Vector{Int}},
                    tlst::Vector{Vector{IntPair}})

        @assert length(nbs) == nv
        @assert length(nbs_lt) == nv
        @assert length(tlst) == nt

        @assert all(length(a) == length(a2) for (a, a2) in zip(nbs, nbs_lt))
        @assert sum(length(a) for a in nbs) == 2 * ne
        @assert sum(length(tl) for tl in tlst) == ne
        new(nv, ne, nt, nbs, nbs_lt, tlst)
    end
end


"""
Construct a simple undirected graph with only one edge type.

# Arguments

- nv:     The number of edges.
- edges:  A collection of edges, where eacn entry is a pair of vertices.
"""
function simple_ugraph(nv::Int, edges)
    nv >= 0 || throw(ArgumentError("nv must be non-negative."))
    edges_ = collect(edges)::Vector{IntPair}
    ne = length(edges)

    nbs = [Int[] for _ = 1:nv]
    nbs_lt = [Int[] for _ = 1:nv]
    for (u, v) in edges_
        0 < u <= nv || throw(BoundsError("Vertex index out of range."))
        0 < v <= nv || throw(BoundsError("Vertex index out of range."))
        u == v && throw(BoundsError("(u, v) can not be the same."))

        push!(nbs[u], v)
        push!(nbs[v], u)
        push!(nbs_lt[u], 1)
        push!(nbs_lt[v], -1)
    end
    UGraph(nv, ne, 1, nbs, nbs_lt, [edges_])
end


"""
Construct an undirected graph (with typed edges).

# Arguments

- nv:      The number of vertices.
- tedges:  A collection of typed edges. ``tedges[i]`` is the
           list of the edges of the ``i``-th type.
"""
function ugraph_with_tedges(nv::Int, tedges)
    nv >= 0 || throw(ArgumentError("nv must be non-negative."))
    tlst = Vector{IntPair}[collect(tl) for tl in tedges]

    ne = 0
    nbs = [Int[] for _ = 1:nv]
    nbs_lt = [Int[] for _ = 1:nv]
    for (t, tl) in enumerate(tlst)
        ne += length(tl)
        for (u, v) in tl
            0 < u <= nv || throw(BoundsError("Vertex index out of range."))
            0 < v <= nv || throw(BoundsError("Vertex index out of range."))
            u == v && throw(BoundsError("(u, v) can not be the same."))

            push!(nbs[u], v)
            push!(nbs[v], u)
            push!(nbs_lt[u], t)
            push!(nbs_lt[v], -t)
        end
    end
    UGraph(nv, ne, length(tlst), nbs, nbs_lt, tlst)
end

nvertices(g::UGraph) = g.nv
nedges(g::UGraph) = g.ne
nedges(g::UGraph, t::Int) = length(g.tlst[t])
vertices(g::UGraph) = 1:g.nv
edges(g::UGraph, t::Int) = g.tlst[t]
degree(g::UGraph, v::Int) = length(g.nbs[v])
neighbors(g::UGraph, v::Int) = g.nbs[v]
neighbor_linktypes(g::UGraph, v::Int) = g.nbs_lt[v]
