Basics
=======

*OpenPPL* is a domain-specific language built on top of Julia using macros. The language consists of two parts: *model specification* and *query*. In particular, a *model specification* formalizes a probabilistic model, which involves declaring variables and specifying relations between them; while a *query* specifies *what is given* and *what is to be inferred*. 

Terminologies
--------------

Here is a list of terminologies that would be involved in the description.

**Variable**
    A variable generally refers to an entity that can take a value of certain type. It can be a random variable directly associated with a distribution, a deterministic transformation of another variable, or just some value given by the user. The value of a variable can be given or unknown. 
    
**Constant**
        A value that is fixed when a query is constructed and fixed throughout the inference procedure. A constant is typically used to represent vector dimensions, model sizes, and hyper-parameters etc. Note that model parameters are typically considered as variables instead of constants. For example, a learning process can be formulated as a query that solves the parameter given a set of observations, where the parameter values can be iteratively updated.
    
**Domain**
    The domain of a variable refers to the set of possible values that it may take. Any Julia type (e.g. ``Int``, ``Float64``) can be considered as a domain that contains any value of that type. This package also supports array domains and restrictive domains that contain only a subset of a specific type. Here are some examples:
    
    .. code-block:: julia
        :linenos:
        
        1..K            # integers between 1 and K
        0.0..Inf        # all non-negative real values
        Float64^n       # n-dimensional real vectors
        Float64^(m,n)   # matrices of size (m, n)
        (0.0..1.0)^m    # m-dimensional real vectors with all components in [0., 1.]
    
**Distribution**
    From a programmatic standpoint, a distribution can be considered as a *stochastic* function that yields a random value in some domain. A distribution can accept zero or more arguments. A distribution should be *stochastically pure*, meaning that it always outputs the same value given the same arguments and the same state of the random number generator. Such purity makes it possible to reason about program structure and transform the model from one form to another.
    
**Factor**
    A factor is a pure real-valued function. Here, "pure" means that it always output the same value given the same inputs. Factors are the core building blocks of a probabilistic model. A complex distribution is typically formulated as a set of variables connected by factors. Even a simple distribution (e.g. normal distribution) consists of a factor that connects between generated variables and parameters (which may be considered as a variable with fixed value). 
    
    
Getting Started: Gaussian Mixture Model
----------------------------------------

Here, we take the *Gaussian Mixture Model* as an example to illustrate how we can specify a probabilistic model using this Julia domain-specific language (DSL). A *Gaussian Mixture Model* is a generative model that combines several Gaussian components to approximate complex distributions (e.g. those with multiple modals.). A Gaussian mixture model is characterized by a prior distribution :math:`\pi` and a set of Gaussian component parameters :math:`(\mu_1, \Sigma_1), \ldots, (\mu_K, \Sigma_K)`. The generative process is described as follows:

    .. math::
    
        z_i &\ \sim \ \pi \\
        x_i | z_i &\ \sim \ \mathcal{N}(\mu_{z_i}, \Sigma_{z_i})
        
Model Specification
~~~~~~~~~~~~~~~~~~~
        
The model specification is given by 

    .. code-block:: julia
        :linenos:
    
        @model GaussianMixtureModel begin
            # constant declaration
            @constant d::Int   # vector dimension            
            @constant n::Int   # number of observations
            @hyperparam K::Int   # number of components
            
            # parameter declaration
            @param pi :: (0.0..1.0)^K    # prior proportions
            for k in 1 : K
                @param mu[k] :: Float64^d         # component mean
                @param sig[k] :: Float64^(d, d)   # component covariance
            end
            
            # sample generation process
            for i in 1 : n
                z[i] ~ Categorical(pi)
                x[i] ~ MultivariateNormal(mu[z[i]], sig[z[i]])
            end
        end
        
This model specification should be self-explanatory. However, it is still worth clarifying several aspects:

* The macro ``@model`` defines a model type named ``GaussianMixtureModel``, and creates an environment (delimited by ``begin`` and ``end``) for model formulation. All model types created by ``@model`` is a sub type of ``AbstractModel``.

* The macro ``@constant`` declares ``d``, ``K``, and ``n`` as constants. The values of these constants need not be given in the specification. Instead, they are needed upon query. Particularly, to construct a model, one can write

    .. code-block:: julia
    
        mdl = GaussianMixtureModel()
        
  One can *optionally* fix the value of constants through keyword arguments in model construction, as below
  
    .. code-block:: julia
     
        mdl = GaussianMixtureModel(d = 2, K = 5)
        
  Note: fixing constants upon model construction is generally unnecessary. However, it might be useful to fix them under certain circumstances to to simplify queries or restrict its use. Once a constant is fixed, it need not be specified again in the query.
  
* The macro ``@hyperparam`` declares hyper parameters. Hyper parameters are similar to constant technically, except that they typically refer to model configurations that may be changed during cross validation.
     
* Variables can be defined using the syntax as ``variable-name :: domain``. A for-loop can be used to declare multiple variables in the same domain. When the variable domain is clear from the context (e.g. the domain of ``z`` and ``x`` can be inferred from where they are drawn), the declaration can be omitted. 

* The macro ``@param`` tags certain variables to be parameters. The information will be used in the learning algorithm to determine which variables are the parameters to estimate. 

* The statement ``variable-name ~ distribution`` introduces a conditional distribution over variables, which will be translated into a factor during model compilation.


Generic Specification: Finite Mixture Model
--------------------------------------------

The Gaussian mixture model can be considered as a special case in a generic family called *Finite mixture model*. Generally, the components of a finite mixture model can be arbitrary distributions. To capture the concept of *generic distribution family*, we introduce *generic specification* (or *parametric specification*), which can take type arguments.

The specification of the generic finite mixture model is given by

    .. code-block:: julia
        :linenos:
    
        @model FiniteMixtureModel{G, ParamTypes} begin
            # constant declaration
            @hyperparam K::Int
            @constant n::Int
            
            # parameter declaration
            @param pi :: (0.0..1.0)^K    # prior proportions
            for k = 1 : K
                for j = 1 : length(ParamTypes)
                    @param theta[k][j] :: ParamTypes[j]
                end
            end
            
            # sample generation process
            for i in 1 : n
                z[i] ~ Categorical(pi)
                x[i] ~ G(theta[z[i]]...)
            end
        end

One may consider a generic specification above as a specification template. To obtain a Gaussian mixture model specification, we can use the ``@modelalias`` macro, as below:

    .. code-block:: julia
        :linenos:
    
        @modelalias GaussianMixtureModel FiniteMixtureModel{G, ParamTypes} begin
            @constant d::Int
            @with G = MultivariateNormal
            @with ParamTypes[1] = Float64^d         # component mean
            @with ParamTypes[2] = Float64^(d, d)    # component covariance
        end
        
        mdl = GaussianMixtureModel()

The ``@modelalias`` macro allows introducing new constants and specializing the type parameters. 


Queries
--------

In machine learning, the most common queries that people would make include

* learning: estimate model parameters
* prediction: predict the value or marginal distribution over unknown variables, given a learned model and observed variables. 
* evaluation: evaluate log-likelihood of observations with a given model
* sampling: draw a set of samples of certain variables

To simplify these common queries, we provide several functions. 

Query
~~~~~~
        
*Query* refers to the task of inferring the value or marginal distributions of unknown variables, given a set of known variables. 

    .. code-block:: julia
        :linenos:
        
        function query(rmdl::AbstractModel, knowns::Associative, qlist::Array, options)
            set_variables!(rmdl, knowns)
            q = compile_query(rmdl, qlist, options) # this returns a query function q
            return q()  # runs the query function and returns the results
        end
        
        function query(rmdl::AbstractModel, knowns::Associative, q)
            infer(rmdl, knowns, q, default_options(rmdl))        
        end
        
``qlist`` is a list of variables or functions over variables that you want to infer. The function ``compile_query`` actually performs model compilation, analyzing model structure, choosing appropriate inference algorithms, and generating a closure ``q``, which, when executed, actually performs the inference.  

This ``query`` function here is very flexible. One can use it for prediction and sampling, etc.

    .. code-block:: julia
        :linenos:
        
        # let rmdl be a learned model
        
        # predict the value of z given observation x
        z_values = query(rmdl, {:x=>columns(data)}, :z)
        
        # infer the posterior marginal distributions over z given x
        z_marginal = query(rmdl, {:x=>columns(data)}, :(marginal(z)))
        
        # you can simultaneously infer only selected variables in a flexible way
        r = query(rmdl, {:x=>columns(data)}, {:(z[1]), :(z[2]), :(marginal(z[3]))})
        
        # draw 100 samples of z
        samples = query(rmdl, {x:=>columns(data)}, :(samples(z, 100)))
        
Note that inputs to the function are symbols like ``:z`` or expressions like ``:(marginal(z))``, which indicate *what we want to query*. It is incorrect to pass ``z`` or ``marginal(z)`` -- the value of ``z`` or ``marginal(z)`` is unavailable before the inference.


Learning
~~~~~~~~

*Learning* refers to the task of estimating model parameters given observed data. This can be considered as a special kind of query, which infers the values of model parameters, given observed data. 

    .. code-block:: julia
        :linenos:
        
        function learn_model(mdl::AbstractModel, data::Associative, options)
            rmdl = copy(mdl)        
            set_variables!(rmdl, data)
            q = compile_query(rmdl, parameters(rmdl), options)
            set_variables!(rmdl, q())
            return rmdl
        end
        
        function learn_model(mdl::AbstractModel, data)
            learn_model(mdl, data, default_options(mdl))
        end
        
        # learn a GMM, a simple wrapper of learn_model  
        # suppose data is a d-by-n matrix        
        rmdl = learn_model(
            GaussianMixtureModel(K = 3, d = size(data,1), n = size(data,2)), 
            {:x => columns(data)})
            
In the function ``learn_model``, ``parameters(rmdl)`` returns a list of parameters as the query list. Then the statement ``q = compile_query(rmdl, parameters(rmdl), options)`` returns a query function ``q``, such that ``q()`` executes the estimation procedure and returns the estimated model parameters. The following example shows how we can use this function to learn a Gaussian mixture model.


    .. code-block:: julia
        :linenos:
        
        function learn_gmm(data::Matrix{Float64}, K::Int)
            learn_model(
                GaussianMixtureModel(K = K, d = size(data,1), n = size(data,2)), 
                {:x => columns(data)})
        end
        
        rmdl_K3 = learn_gmm(data, 3)
        rmdl_K5 = learn_gmm(data, 5)
        
Here, ``learn_gmm`` is a light-weight wrapper of ``learn_model``.
        
        
Evaluation
~~~~~~~~~~~

*Evaluation* refers to the task of evaluating log-pdf of samples with respect to a learned model. 

    .. code-block:: julia
        
        # evaluate the logpdf of x with respect to a GMM
        lp = query(rmdl, {:x=>columns(data)}, :(logpdf(x)))

Options
~~~~~~~~

The compilation options that control how the query is compiled can be specified through the ``options`` argument in the ``query`` or ``learn_model`` function. The following is some examples

    .. code-block:: julia
    
        rmdl = learn_model(mdl, data, {:method=>"variational_em", :max_iter=>100, :tolerance=1.0e-6})

For sampling, we may use a different set of options

    .. code-block:: julia
    
        options = {
            :method=>"gibbs_sampling",  # choose to use Gibbs sampling
            :burnin=>5000,              # the number of burn-in iterations
            :lag=>100}                  # the interval between two samples to retain
    
        samples = query(rmdl, {x:=>columns(data)}, :(samples(z, 100)), options)


Query Functions with Arguments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is often desirable in practice that a query function can be applied to different data sets without being re-compiled. For this purpose, we introduce a function ``make_query_function``. The following example illustrates its use:

    .. code-block:: julia
        :linenos:
    
        # suppose rmdl is a learned model
        
        q = make_query_function(rmdl, 
            (:data,),  # indicates that the function q would take one argument data
            {:x=>:(columns(data))},  # indicates how the argument is set to the model as a known value
            {:z},      # specifies what to query
            options)   # compilation options
            
        # q can be repeatedly use for different datasets (without being re-compiled)
        z1 = q(x1)
        z2 = q(x2)
        
Note that ``q`` is a closure that holds reference to the learned model, so you don't have to pass the model as an argument into ``q``. The following code use this mechanism to generate a sampler:

    .. code-block:: julia
        :linenos:
    
        q = make_query_function(rmdl, 
            (:data, :n), # q would take two arguments, the observed data and the number of samples
            {:x=>:(columns(data))}, 
            {:sample(z, n)},
            options)
            
        # draw 100 samples of z
        zs1 = q(x, 100)
        
        # draw another 200 samples of z
        zs2 = q(x, 200)
        
