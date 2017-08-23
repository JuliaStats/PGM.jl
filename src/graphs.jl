
const IntPair = Tuple{Int,Int}

"""
Undirected graph
"""
mutable struct UGraph
    nv::Int     # number of vertices
    ne::Int     # number of undirected edges
    nt::Int     # number of edge types

    # adjacency list
    # each vertex u is associated with a list of pairs, with
    # each pair in the form of (v, t). Here, 'v' is the index
    # of the vertex at the other end, and 't' is the signed type
    # of the edge. For example,
    # a pair `(v, 2)` indicates an edge `(u, v)` of the 2nd type,
    # a pair `(v, -3)` indicates an edge `(v, u)` of the 3rd type.
    # Please note the position of `v` in the vertex pair.
    #
    adj::Vector{Vector{IntPair}}

    # collected typed edge list
    # each entry is a list of edges of the corresponding type
    tlst::Vector{Vector{IntPair}}

    function UGraph(nv::Int, ne::Int, nt::Int,
                    adj::Vector{Vector{IntPair}},
                    tlst::Vector{Vector{IntPair}})

        @assert length(adj) == nv
        @assert length(tlst) == nt
        @assert sum(length(a) for a in adj) == 2 * ne
        @assert sum(length(tl) for tl in tlst) == ne
        new(nv, ne, nt, adj, tlst)
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

    adj = [IntPair[] for _ = 1:nv]
    for (u, v) in edges_
        0 < u <= nv || throw(BoundsError("Vertex index out of range."))
        0 < v <= nv || throw(BoundsError("Vertex index out of range."))

        push!(adj[u], (v, 1))
        push!(adj[v], (u, -1))
    end
    UGraph(nv, ne, 1, adj, [edges_])
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
    adj = [IntPair[] for _ = 1:nv]
    for (t, tl) in enumerate(tlst)
        ne += length(tl)
        for (u, v) in tl
            0 < u <= nv || throw(BoundsError("Vertex index out of range."))
            0 < v <= nv || throw(BoundsError("Vertex index out of range."))

            push!(adj[u], (v, t))
            push!(adj[v], (u, -t))
        end
    end
    UGraph(nv, ne, length(tlst), adj, tlst)
end

nvertices(g::UGraph) = g.nv
nedges(g::UGraph) = g.ne
nedges(g::UGraph, t::Int) = length(g.tlst[t])
vertices(g::UGraph) = 1:g.nv
edges(g::UGraph, t::Int) = g.tlst[t]
degree(g::UGraph, v::Int) = length(g.adj[v])
adjlist(g::UGraph, v::Int) = g.adj[v]
