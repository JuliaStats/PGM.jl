module PGM

import Base: ==, !=
import Base: eltype, ndims, size, length, show, keys, values, parent
import Base: getindex, eachindex, start, next, done

export
    # variables
    ValueSpace,
    RealSpace,
    FiniteSpace,
    RangeSpace,
    Var,
    DVar,
    RVar,
    VarList,

    indexof,
    dvar,
    rvar,

    # graphs
    Tree,
    UGraph,

    nvertices,
    nedges,
    nedgetypes,
    vertices,
    root,
    isroot,
    isleaf,
    edges,
    degree,
    parent,
    parent_linktype,
    children,
    children_linktypes,
    neighbors,
    neighbor_linktypes,
    simple_ugraph,
    ugraph_with_tedges,
    to_tree,

    # discrete
    JointPMF,
    DiscretePairwiseMRF,

    nvars,
    vars,
    probs,
    marginal_i,
    marginal,
    conditional,
    pwmrf,
    has_vertex_potentials,
    has_edge_potentials,
    set_vertex_potentials!,
    set_edge_potentials!,
    vertex_potentials,
    edge_potentials,
    var_cardinalities,
    edge_pdims,
    tpotential,
    tpotentials

# sources

include("utils.jl")
include("variables.jl")
include("graphs.jl")

include("discrete/jointpmf.jl")
include("discrete/dmrf.jl")

end # module
