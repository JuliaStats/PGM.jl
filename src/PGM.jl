module PGM

import Base: ==, !=
import Base: eltype, ndims, size, length, show, keys, values, parent
import Base: getindex, eachindex, start, next, done

export
    # lists
    GroupedList,
    NamedList,

    grlist_from_counts,
    grlist_by,
    ngroups,
    group,
    group_length,
    namedlist,
    namedlist_from_pairs,
    indexof,

    # variables
    VType,
    Var,
    SVar,

    realv,
    intv,
    dvar,
    rvar,
    vtype,
    cardinality,
    varlist,

    # graphs
    Edge,
    # Tree,
    UGraph,

    nvertices,
    nedges,
    nedgekinds,
    vertices,
    edges,
    edges_of,
    indegree_at,
    outdegree_at,
    degree_at,
    inedges_at,
    outedges_at

    # discrete
    # JointPMF,
    # DiscretePairwiseMRF,
    #
    # nvars,
    # vars,
    # probs,
    # marginal_i,
    # marginal,
    # conditional,
    # pwmrf,
    # has_vertex_potentials,
    # has_edge_potentials,
    # set_vertex_potentials!,
    # set_edge_potentials!,
    # vertex_potentials,
    # edge_potentials,
    # var_cardinalities,
    # edge_pdims,
    # tpotential,
    # tpotentials

# sources

include("utils.jl")
include("lists.jl")
include("variables.jl")
include("graphs.jl")

# include("discrete/jointpmf.jl")
# include("discrete/dmrf.jl")

end # module
