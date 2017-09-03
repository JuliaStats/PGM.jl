
@enum VType realv intv

"""
Random variable.

``Var`` is a parametric type with a type parameter N, which indicates
the number of dimensions for each sample.

Each instance of ``Var`` represents a random variable that can take
different values in different trials. The instance contains four
public fields:

- ``id::String``:       The identifier of the variable. In a joint model,
                        each variable should have a unique id.
- ``space::S``:         The underlying value space (for each element).
- ``dims::Dims{N}``:    The dimensions of each sample.
- ``len::Int``:         The number of elements in each sample
                        (i.e. ``prod(size)``).
"""
mutable struct Var{N}
    id::String          # identifier
    vtype::VType        # variable type (realv or intv)
    card::Int           # cardinality (0 when it is infinity)
    dims::Dims{N}       # dimensions for each sample
    len::Int            # number of elements of each sample
end

"""Scalar random variable."""
const SVar = Var{0}

dvar(id::String, c::Int) = Var{0}(id, intv, c, (), 1)
dvar(id::String, c::Int, n::Int) = Var{1}(id, intv, c, (n,), n)
dvar{N}(id::String, c::Int, dims::Dims{N}) = Var{N}(id, intv, c, dims, prod(dims))

rvar(id::String) = Var{0}(id, realv, 0, (), 1)
rvar(id::String, n::Int) = Var{1}(id, realv, 0, (n,), n)
rvar{N}(id::String, dims::Dims{N}) = Var{N}(id, realv, 0, dims, prod(dims))

ndims{N}(v::Var{N}) = N
size(v::Var) = v.dims
length(v::Var) = v.len
vtype(v::Var) = v.vtype
cardinality(v::Var) = v.card

==(x::Var, y::Var) = false
=={N}(x::Var{N}, y::Var{N}) =
    (x.id == y.id && x.vtype == y.vtype && x.card == y.card && x.dims == y.dims)
!=(x::Var, y::Var) = !(x == y)

function show(io::IO, v::Var)
    print(io, "Var($(v.id))[vtype=$(v.vtype), dims=$(v.dims)]")
end


const VarList{N} = NamedList{Var{N}}
const SVarList = VarList{0}

varlist{N}(vars::AbstractVector{Var{N}}) =
    namedlist(vars, v->v.id)::VarList{N}
