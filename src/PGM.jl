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

    nvars,
    vars,
    probs,
    marginal_i,
    marginal,
    conditional

# sources

include("utils.jl")
include("variables.jl")
include("graphs.jl")

include("discrete/jointpmf.jl")

end # module
