

"""
Discrete pairwise Markov random field
"""
mutable struct DiscretePairwiseMRF{T<:AbstractFloat}
    varlist::SVarList
    gr::UGraph
    cards::Vector{Int}
    epdims::Vector{IntPair}

    # vertex potentials: unary potentials associated with vertices
    vpots::Vector{Vector{T}}

    # edge potentials: binary potentials associated with edge types
    epots::Vector{Matrix{T}}

    function DiscretePairwiseMRF{T}(vs::SVarList, gr::UGraph) where T<:AbstractFloat
        nv = length(vs)
        nvertices(gr) == nv || throw(
            ArgumentError("nvertices(gr) does not match #variables."))
        nt = nedgetypes(gr)

        cards = Vector{Int}(nv)
        for (i, v) in enumerate(vs)
            cards[i] = cardinality(v)
        end

        epdims = fill((0, 0), nt)
        for i = 1:nt
            es = edges(gr, i)
            if isempty(es)
                continue
            end
            (u1, v1) = first(es)
            cu, cv = cards[u1], cards[v1]
            for (u, v) in es
                (cards[u] == cu && cards[v] == cv) || throw(
                    DimensionMismatch("Inconsistent edge cardinalities."))
            end
            epdims[i] = (cu, cv)
        end
        new(vs, gr, cards, epdims, Vector{T}[], Matrix{T}[])
    end
end

nvars(mrf::DiscretePairwiseMRF) = length(mrf.varlist)
nvertices(mrf::DiscretePairwiseMRF) = nvertices(mrf.gr)
nedges(mrf::DiscretePairwiseMRF) = nedges(mrf.gr)
nedgetypes(mrf::DiscretePairwiseMRF) = nedgetypes(mrf.gr)
edges(mrf::DiscretePairwiseMRF, t::Int) = edges(mrf.gr, t)
vars(mrf::DiscretePairwiseMRF) = mrf.varlist
var_cardinalities(mrf::DiscretePairwiseMRF, v::Int) = mrf.cards[v]
edge_pdims(mrf::DiscretePairwiseMRF, t::Int) = mrf.epdims[t]

has_vertex_potentials(mrf::DiscretePairwiseMRF) = !isempty(mrf.vpots)
has_edge_potentials(mrf::DiscretePairwiseMRF) = !isempty(mrf.epots)
vertex_potentials(mrf::DiscretePairwiseMRF) = mrf.vpots
edge_potentials(mrf::DiscretePairwiseMRF) = mrf.epots



function set_vertex_potentials!{T<:AbstractFloat}(mrf::DiscretePairwiseMRF{T},
                                                  vpots::Vector{Vector{T}})
    nv = nvertices(mrf)
    length(vpots) == nv || throw(DimensionMismatch(
        "length(vpots) does not match the number of vertices."))

    vs = vars(mrf)
    for i = 1:nv
        if !isempty(vpots[i])
            length(vpots[i]) == mrf.cards[i] || throw(
                DimensionMismatch("Mismatched unary potential size."))
        end
    end
    mrf.vpots = vpots
end

function set_edge_potentials!{T<:AbstractFloat}(mrf::DiscretePairwiseMRF{T},
                                                epots::Vector{Matrix{T}})
    nt = nedgetypes(mrf)
    length(epots) == nt || throw(DimensionMismatch(
        "length(epots) does not match the number of edge types."))

    for i = 1:nt
        if !isempty(epots[i])
            size(epots[i]) == mrf.epdims[i] || throw(
                DimensionMismatch("Mismatched binary potential size."))
        end
    end
    mrf.epots = epots
end

function pwmrf{T<:AbstractFloat}(vs::SVarList, gr::UGraph,
                                 vpots::Vector{Vector{T}},
                                 epots::Vector{Matrix{T}})
    mrf = DiscretePairwiseMRF{T}(vs, gr)
    set_vertex_potentials!(mrf, vpots)
    set_edge_potentials!(mrf, epots)
    mrf
end

function tpotential{T<:AbstractFloat}(mrf::DiscretePairwiseMRF{T},
                                      x::Vector{Int})
    nv = nvertices(mrf)
    nt = nedgetypes(mrf)
    length(x) == nv || throw(DimensionMismatch("Invalid sample dimension."))

    # accumulate vertex potentials
    r1 = zero(T)
    if has_vertex_potentials(mrf)
        vpots = vertex_potentials(mrf)
        for i = 1:nv
            vp = vpots[i]
            isempty(vp) && continue
            r1 += vp[x[i]]
        end
    end

    # accumulate edge potentials
    r2 = zero(T)
    if has_edge_potentials(mrf)
        epots = edge_potentials(mrf)
        for t = 1:nt
            ep = epots[t]
            isempty(ep) && continue
            r2t = zero(T)
            es = edges(mrf, t)
            for (u, v) in es
                r2t += ep[x[u], x[v]]
            end
            r2 += r2t
        end
    end

    # total potential
    r1 + r2
end

function tpotentials{T<:AbstractFloat}(mrf::DiscretePairwiseMRF{T})
    nv = nvertices(mrf)
    nt = nedgetypes(mrf)

    # prepare storage
    r = zeros(T, mrf.cards...)

    # accumulate vertex potentials
    if has_vertex_potentials(mrf)
        vpots = vertex_potentials(mrf)
        for i = 1:nv
            vp = vpots[i]
            if !isempty(vp)
                shp = ones(Int, nv)
                shp[i] = mrf.cards[i]
                r .+= reshape(vp, shp...)
            end
        end
    end

    # accumulate edge potentials
    if has_edge_potentials(mrf)
        epots = edge_potentials(mrf)
        for t = 1:nt
            ep = epots[t]
            if !isempty(ep)
                ep_t = transpose(ep)
                es = edges(mrf, t)
                for (u, v) in es
                    @assert u != v
                    shp = ones(Int, nv)
                    shp[u] = size(ep, 1)
                    shp[v] = size(ep, 2)
                    if u < v
                        r .+= reshape(ep, shp...)
                    else
                        r .+= reshape(ep_t, shp...)
                    end
                end
            end
        end
    end
    r
end
