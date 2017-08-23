module PGM

import Base: ==, !=
import Base: eltype, ndims, size, length, show, keys, values
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
    UGraph,

    nvertices,
    nedges,
    vertices,
    edges,
    degree,
    adjlist,
    simple_ugraph,
    ugraph_with_tedges,

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
