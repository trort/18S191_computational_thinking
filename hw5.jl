### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 2b37ca3a-0970-11eb-3c3d-4f788b411d1a
begin
	using Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 2dcb18d0-0970-11eb-048a-c1734c6db842
begin
	Pkg.add(["PlutoUI", "Plots", "Statistics"])

	using Plots
	gr()
	using PlutoUI
	using Statistics
end

# ╔═╡ 19fe1ee8-0970-11eb-2a0d-7d25e7d773c6
md"_homework 5, version 0_"

# ╔═╡ 49567f8e-09a2-11eb-34c1-bb5c0b642fe8
# WARNING FOR OLD PLUTO VERSIONS, DONT DELETE ME

html"""
<script>
const warning = html`
<h2 style="color: #800">Oopsie! You need to update Pluto to the latest version for this homework</h2>
<p>Close Pluto, go to the REPL, and type:
<pre><code>julia> import Pkg
julia> Pkg.update("Pluto")
</code></pre>
`

const super_old = window.version_info == null || window.version_info.pluto == null
if(super_old) {
	return warning
}
const version_str = window.version_info.pluto.substring(1)
const numbers = version_str.split(".").map(Number)
console.log(numbers)

if(numbers[0] > 0 || numbers[1] > 12 || numbers[2] > 1) {
	
} else {
	return warning
}

</script>

"""

# ╔═╡ 181e156c-0970-11eb-0b77-49b143cc0fc0
md"""

# **Homework 5**: _Epidemic modeling II_
`18.S191`, fall 2020

This notebook contains _built-in, live answer checks_! In some exercises you will see a coloured box, which runs a test case on your code, and provides feedback based on the result. Simply edit the code, run it, and the check runs again.

_For MIT students:_ there will also be some additional (secret) test cases that will be run as part of the grading process, and we will look at your notebook and write comments.

Feel free to ask questions!
"""

# ╔═╡ 1f299cc6-0970-11eb-195b-3f951f92ceeb
# edit the code below to set your name and kerberos ID (i.e. email without @mit.edu)

student = (name = "trort", kerberos_id = "000")

# you might need to wait until all other cells in this notebook have completed running. 
# scroll around the page to see what's up

# ╔═╡ 1bba5552-0970-11eb-1b9a-87eeee0ecc36
md"""

Submission by: **_$(student.name)_** ($(student.kerberos_id)@mit.edu)
"""

# ╔═╡ 2848996c-0970-11eb-19eb-c719d797c322
md"_Let's create a package environment:_"

# ╔═╡ 69d12414-0952-11eb-213d-2f9e13e4b418
md"""
In this problem set, we will look at a simple **spatial** agent-based epidemic model: agents can interact only with other agents that are *nearby*.  (In the previous homework any agent could interact with any other, which is not realistic.)

A simple approach is to use **discrete space**: each agent lives
in one cell of a square grid. For simplicity we will allow no more than
one agent in each cell, but this requires some care to
design the rules of the model to respect this.

We will adapt some functionality from the previous homework. You should copy and paste your code from that homework into this notebook.
"""

# ╔═╡ 3e54848a-0954-11eb-3948-f9d7f07f5e23
md"""
## **Exercise 1:** _Wandering at random in 2D_

In this exercise we will implement a **random walk** on a 2D lattice (grid). At each time step, a walker jumps to a neighbouring position at random (i.e. chosen with uniform probability from the available adjacent positions).

"""

# ╔═╡ 3e623454-0954-11eb-03f9-79c873d069a0
md"""
#### Exercise 1.1
We define a struct type `Coordinate` that contains integers `x` and `y`.
"""

# ╔═╡ 0ebd35c8-0972-11eb-2e67-698fd2d311d2
struct Coordinate
	x::Int
	y::Int
end

# ╔═╡ 027a5f48-0a44-11eb-1fbf-a94d02d0b8e3
md"""
👉 Construct a `Coordinate` located at the origin.
"""

# ╔═╡ b2f90634-0a68-11eb-1618-0b42f956b5a7
origin = Coordinate(0, 0)

# ╔═╡ 3e858990-0954-11eb-3d10-d10175d8ca1c
md"""
👉 Write a function `make_tuple` that takes an object of type `Coordinate` and returns the corresponding tuple `(x, y)`. Boring, but useful later!
"""

# ╔═╡ 189bafac-0972-11eb-1893-094691b2073c
function make_tuple(c::Coordinate)
	(c.x, c.y)
end

# ╔═╡ 73ed1384-0a29-11eb-06bd-d3c441b8a5fc
md"""
#### Exercise 1.2
In Julia, operations like `+` and `*` are just functions, and they are treated like any other function in the language. The only special property you can use the _infix notation_: you can write
```julia
1 + 2
```
instead of 
```julia
+(1, 2)
```
_(There are [lots of special 'infixable' function names](https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm#L23-L24) that you can use for your own functions!)_

When you call it with the prefix notation, it becomes clear that it really is 'just another function', with lots of predefined methods.
"""

# ╔═╡ 96707ef0-0a29-11eb-1a3e-6bcdfb7897eb
+(1, 2)

# ╔═╡ b0337d24-0a29-11eb-1fab-876a87c0973f
+

# ╔═╡ 9c9f53b2-09ea-11eb-0cda-639764250cee
md"""
> #### Extending + in the wild
> Because it is a function, we can add our own methods to it! This feature is super useful in general languages like Julia and Python, because it lets you use familiar syntax (`a + b*c`) on objects that are not necessarily numbers!
> 
> One example we've see before is the `RGB` type in Homework 1. You are able to do:
> ```julia
> 0.5 * RGB(0.1, 0.7, 0.6)
> ```
> to multiply each color channel by $0.5$. This is possible because `Images.jl` [wrote a method](https://github.com/JuliaGraphics/ColorVectorSpace.jl/blob/master/src/ColorVectorSpace.jl#L131):
> ```julia
> *(::Real, ::AbstractRGB)::AbstractRGB
> ```

👉 Implement addition on two `Coordinate` structs by adding a method to `Base.:+`
"""

# ╔═╡ e24d5796-0a68-11eb-23bb-d55d206f3c40
function Base.:+(a::Coordinate, b::Coordinate)
	return Coordinate(a.x + b.x, a.y + b.y)
end

# ╔═╡ ec8e4daa-0a2c-11eb-20e1-c5957e1feba3
Coordinate(3,4) + Coordinate(10,10) # uncomment to check + works

# ╔═╡ e144e9d0-0a2d-11eb-016e-0b79eba4b2bb
md"""
_Pluto has some trouble here, you need to manually re-run the cell above!_
"""

# ╔═╡ 71c358d8-0a2f-11eb-29e1-57ff1915e84a
md"""
#### Exercise 1.3
In our model, agents will be able to walk in 4 directions: up, down, left and right. We can define these directions as `Coordinate`s.
"""

# ╔═╡ 5278e232-0972-11eb-19ff-a1a195127297
# uncomment this:

possible_moves = [
	Coordinate( 1, 0), 
	Coordinate( 0, 1), 
	Coordinate(-1, 0), 
	Coordinate( 0,-1),
]

# ╔═╡ 71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
md"""
👉 `rand(possible_moves)` gives a random possible move. Add this to the coordinate `Coordinate(4,5)` and see that it moves to a valid neighbor.
"""

# ╔═╡ 69151ce6-0aeb-11eb-3a53-290ba46add96
Coordinate(4,5) + rand(possible_moves)

# ╔═╡ 3eb46664-0954-11eb-31d8-d9c0b74cf62b
md"""
We are able to make a `Coordinate` perform one random step, by adding a move to it. Great!

👉 Write a function `trajectory` that calculates a trajectory of a `Wanderer` `w` when performing `n` steps., i.e. the sequence of positions that the walker finds itself in.

Possible steps:
- Use `rand(possible_moves, n)` to generate a vector of `n` random moves. Each possible move will be equally likely.
- To compute the trajectory you can use either of the following two approaches:
  1. 🆒 Use the function `accumulate` (see the live docs for `accumulate`). Use `+` as the function passed to `accumulate` and the `w` as the starting value (`init` keyword argument). 
  1. Use a `for` loop calling `+`. 

"""

# ╔═╡ edf86a0e-0a68-11eb-2ad3-dbf020037019
function trajectory(w::Coordinate, n::Int)
	moves = rand(possible_moves, n)
	traj = accumulate(+, moves; init = w)
	return traj
end

# ╔═╡ 478309f4-0a31-11eb-08ea-ade1755f53e0
function plot_trajectory!(p::Plots.Plot, trajectory::Vector; kwargs...)
	plot!(p, make_tuple.(trajectory); 
		label=nothing, 
		linewidth=2, 
		linealpha=LinRange(1.0, 0.2, length(trajectory)),
		kwargs...)
end

# ╔═╡ 3ebd436c-0954-11eb-170d-1d468e2c7a37
md"""
#### Exercise 1.4
👉 Plot 10 trajectories of length 1000 on a single figure, all starting at the origin. Use the function `plot_trajectory!` as demonstrated above.

Remember from last week that you can compose plots like this:

```julia
let
	# Create a new plot with aspect ratio 1:1
	p = plot(ratio=1)

	plot_trajectory!(p, test_trajectory)      # plot one trajectory
	plot_trajectory!(p, another_trajectory)   # plot the second one
	...

	p
end
```
"""

# ╔═╡ b4d5da4a-09a0-11eb-1949-a5807c11c76c
md"""
#### Exercise 1.5
Agents live in a box of side length $2L$, centered at the origin. We need to decide (i.e. model) what happens when they reach the walls of the box (boundaries), in other words what kind of **boundary conditions** to use.

One relatively simple boundary condition is a **collision boundary**:

> Each wall of the box is a wall, modelled using "collision": if the walker tries to jump beyond the wall, it ends up at the position inside the box that is closest to the goal.

👉 Write a function `collide_boundary` which takes a `Coordinate` `c` and a size $L$, and returns a new coordinate that lies inside the box (i.e. ``[-L,L]\times [-L,L]``), but is closest to `c`. This is similar to `extend_mat` from Homework 1.
"""

# ╔═╡ 0237ebac-0a69-11eb-2272-35ea4e845d84
function collide_boundary(c::Coordinate, L::Number)
	return Coordinate(clamp(c.x, -L, L), clamp(c.y, -L, L))
end

# ╔═╡ ad832360-0a40-11eb-2857-e7f0350f3b12
collide_boundary(Coordinate(12,4), 10) # uncomment to test

# ╔═╡ b4ed2362-09a0-11eb-0be9-99c91623b28f
md"""
#### Exercise 1.6
👉  Implement a 3-argument method  of `trajectory` where the third argument is a size. The trajectory returned should be within the boundary (use `collide_boundary` from above). You can still use `accumulate` with an anonymous function that makes a move and then reflects the resulting coordinate, or use a for loop.

"""

# ╔═╡ 0665aa3e-0a69-11eb-2b5d-cd718e3c7432
begin	
	function trajectory(c::Coordinate, n::Int, L::Number)
		function collide_boundary_add(a::Coordinate, b::Coordinate)
			collide_boundary(a+b, L)
		end
		
		moves = rand(possible_moves, n)
		traj = accumulate(collide_boundary_add, moves; init = c)
		return traj
	end
end

# ╔═╡ 44107808-096c-11eb-013f-7b79a90aaac8
test_trajectory = trajectory(Coordinate(4,4), 30) # uncomment to test

# ╔═╡ 87ea0868-0a35-11eb-0ea8-63e27d8eda6e
try
	p = plot(ratio=1, size=(650,200))
	plot_trajectory!(p, test_trajectory; color="black", showaxis=false, axis=nothing, linewidth=4)
	p
catch
end

# ╔═╡ 51788e8e-0a31-11eb-027e-fd9b0dc716b5
let
	long_trajectory = trajectory(Coordinate(4,4), 1000)

	p = plot(ratio=1)
	plot_trajectory!(p, long_trajectory)
	p
end

# ^ uncomment to visualize a trajectory

# ╔═╡ dcefc6fe-0a3f-11eb-2a96-ddf9c0891873
let
	p = plot(ratio=1)
	for _ in 1:10
		long_trajectory = trajectory(origin, 200, 10)
		plot_trajectory!(p, long_trajectory)
	end
	p
end

# ╔═╡ 3ed06c80-0954-11eb-3aee-69e4ccdc4f9d
md"""
## **Exercise 2:** _Wanderering Agents_

In this exercise we will create Agents which have a location as well as some infection state information.

Let's define a type `Agent`. `Agent` contains a `position` (of type `Coordinate`), as well as a `status` of type `InfectionStatus` (as in Homework 4).)

(For simplicity we will not use a `num_infected` field, but feel free to do so!)
"""

# ╔═╡ 35537320-0a47-11eb-12b3-931310f18dec
@enum InfectionStatus S I R

# ╔═╡ 814e888a-0954-11eb-02e5-0964c7410d30
md"""
#### Exercise 2.1
👉 Write a function `initialize` that takes parameters $N$ and $L$, where $N$ is the number of agents abd $2L$ is the side length of the square box where the agents live.

It returns a `Vector` of `N` randomly generated `Agent`s. Their coordinates are randomly sampled in the ``[-L,L] \times [-L,L]`` box, and the agents are all susceptible, except one, chosen at random, which is infectious.
"""

# ╔═╡ e0b0880c-0a47-11eb-0db2-f760bbbf9c11
# Color based on infection status
color(s::InfectionStatus) = if s == S
	"blue"
elseif s == I
	"red"
else
	"gray"
end

# ╔═╡ 49fa8092-0a43-11eb-0ba9-65785ac6a42f
md"""
#### Exercise 2.2
👉 Write a function `visualize` that takes in a collection of agents as argument, and the box size `L`. It should plot a point for each agent at its location, coloured according to its status.

You can use the keyword argument `c=color.(agents)` inside your call to the plotting function make the point colors correspond to the infection statuses. Don't forget to use `ratio=1`.
"""

# ╔═╡ f953e06e-099f-11eb-3549-73f59fed8132
md"""

### Exercise 3: Spatial epidemic model -- Dynamics

Last week we wrote a function `interact!` that takes two agents, `agent` and `source`, and an infection of type `InfectionRecovery`, which models the interaction between two agent, and possibly modifies `agent` with a new status.

This week, we define a new infection type, `CollisionInfectionRecovery`, and a new method that is the same as last week, except it **only infects `agent` if `agents.position==source.position`**.
"""	

# ╔═╡ e6dd8258-0a4b-11eb-24cb-fd5b3554381b
abstract type AbstractInfection end

# ╔═╡ de88b530-0a4b-11eb-05f7-85171594a8e8
struct CollisionInfectionRecovery <: AbstractInfection
	p_infection::Float64
	p_recovery::Float64
end

# ╔═╡ 80f39140-0aef-11eb-21f7-b788c5eab5c9
md"""

Write a function `interact!` that takes two `Agent`s and a `CollisionInfectionRecovery`, and:

- If the agents are at the same spot, causes a susceptible agent to communicate the desease from an infectious one with the correct probability.
- if the first agent is infectious, it recovers with some probability
"""

# ╔═╡ 34778744-0a5f-11eb-22b6-abe8b8fc34fd
md"""
#### Exercise 3.1
Your turn!

👉 Write a function `step!` that takes a vector of `Agent`s, a box size `L` and an `infection`. This that does one step of the dynamics on a vector of agents. 

- Choose an Agent `source` at random.

- Move the `source` one step, and use `collide_boundary` to ensure that our agent stays within the box.

- For all _other_ agents, call `interact!(other_agent, source, infection)`.

- return the array `agents` again.
"""

# ╔═╡ 1fc3271e-0a45-11eb-0e8d-0fd355f5846b
md"""
#### Exercise 3.2
If we call `step!` `N` times, then every agent will have made one step, on average. Let's call this one _sweep_ of the simulation.

👉 Create a before-and-after plot of ``k_{sweeps}=1000`` sweeps. 

- Initialize a new vector of agents (`N=50`, `L=40`, `infection` is given as `pandemic` below). 
- Plot the state using `visualize`, and save the plot as a variable `plot_before`.
- Run `k_sweeps` sweeps.
- Plot the state again, and store as `plot_after`.
- Combine the two plots into a single figure using
```julia
plot(plot_before, plot_after)
```
"""

# ╔═╡ 18552c36-0a4d-11eb-19a0-d7d26897af36
pandemic = CollisionInfectionRecovery(0.5, 0.00001)

# ╔═╡ 4e7fd58a-0a62-11eb-1596-c717e0845bd5
@bind k_sweeps Slider(1:10000, default=1000, show_value=true)

# ╔═╡ e964c7f0-0a61-11eb-1782-0b728fab1db0
md"""
#### Exercise 3.3

Every time that you move the slider, a completely new simulation is created an run. This makes it hard to view the progress of a single simulation over time. So in this exercise, we we look at a single simulation, and plot the S, I and R curves.

👉 Plot the SIR curves of a single simulation, with the same parameters as in the previous exercise. Use `k_sweep_max = 10000` as the total number of sweeps.
"""

# ╔═╡ 4d83dbd0-0a63-11eb-0bdc-757f0e721221
k_sweep_max = 10000

# ╔═╡ 201a3810-0a45-11eb-0ac9-a90419d0b723
md"""
#### Exercise 3.4 (optional)
Let's make our plot come alive! There are two options to make our visualization dynamic:

👉1️⃣ Precompute one simulation run and save its intermediate states using `deepcopy`. You can then write an interactive visualization that shows both the state at time $t$ (using `visualize`) and the history of $S$, $I$ and $R$ from time $0$ up to time $t$. $t$ is controlled by a slider.

👉2️⃣ Use `@gif` from Plots.jl to turn a sequence of plots into an animation. Be careful to skip about 50 sweeps between each animation frame, otherwise the GIF becomes too large.

This an optional exercise, and our solution to 2️⃣ is given below.
"""

# ╔═╡ 2031246c-0a45-11eb-18d3-573f336044bf
md"""
#### Exercise 3.5
👉  Using $L=20$ and $N=100$, experiment with the infection and recovery probabilities until you find an epidemic outbreak. (Take the recovery probability quite small.) Modify the two infections below to match your observations.
"""

# ╔═╡ 63dd9478-0a45-11eb-2340-6d3d00f9bb5f
causes_outbreak = CollisionInfectionRecovery(0.5, 3E-5)

# ╔═╡ 269955e4-0a46-11eb-02cc-1946dc918bfa
does_not_cause_outbreak = CollisionInfectionRecovery(0.5, 3E-4)

# ╔═╡ 20477a78-0a45-11eb-39d7-93918212a8bc
md"""
#### Exercise 3.6
👉 With the parameters of Exercise 3.2, run 50 simulations. Plot $S$, $I$ and $R$ as a function of time for each of them (with transparency!). This should look qualitatively similar to what you saw in the previous homework. You probably need different `p_infection` and `p_recovery` values from last week. Why?
"""

# ╔═╡ b1b1afda-0a66-11eb-2988-752405815f95
need_different_parameters_because = md"""
i say so because now two agents will interact only when they are at the same position.
"""

# ╔═╡ 05c80a0c-09a0-11eb-04dc-f97e306f1603
md"""
## **Exercise 4:** _Effect of socialization_

In this exercise we'll modify the simple mixing model. Instead of a constant mixing probability, i.e. a constant probability that any pair of people interact on a given day, we will have a variable probability associated with each agent, modelling the fact that some people are more or less social or contagious than others.
"""

# ╔═╡ b53d5608-0a41-11eb-2325-016636a22f71
md"""
#### Exercise 4.1
We create a new agent type `SocialAgent` with fields `position`, `status`, `num_infected`, and `social_score`. The attribute `social_score` represents an agent's probability of interacting with any other agent in the population.
"""

# ╔═╡ c704ea4c-0aec-11eb-2f2c-859c954aa520
md"""define the `position` and `color` methods for `SocialAgent` as we did for `Agent`. This will allow the `visualize` function to work. on both kinds of Agents"""

# ╔═╡ e97e39aa-0a5d-11eb-3d5f-f90a0acfe5a2
# begin
# 	position(a::SocialAgent) = a.position
# 	color(a::SocialAgent) = color(a.status)
# end

# ╔═╡ b554b654-0a41-11eb-0e0d-e57ff68ced33
md"""
👉 Create a function `initialize_social` that takes `N` and `L`, and creates N agents  within a 2L x 2L box, with `social_score`s chosen from 10 equally-spaced between 0.1 and 0.5. (see LinRange)
"""

# ╔═╡ 18ac9926-0aed-11eb-034f-e9849b71c9ac
md"""
Now that we have 2 agent types

1. let's create an AbstractAgent type
2. Go back in the notebook and make the agent types a subtype of AbstractAgent.

"""

# ╔═╡ e73f0f92-5ec5-11eb-28f8-4da4202b98a7
abstract type AbstractAgent end

# ╔═╡ cf2f3b98-09a0-11eb-032a-49cc8c15e89c
# define agent struct here:
mutable struct Agent <: AbstractAgent
	position::Coordinate
	status::InfectionStatus
end

# ╔═╡ 0cfae7ba-0a69-11eb-3690-d973d70e47f4
begin
	function rand_Coordinate(L::Int)
		return Coordinate(rand(-L:L), rand(-L:L))
	end
	
	function initialize(N::Number, L::Number)
		Agents = [Agent(rand_Coordinate(L), S) for _ in 1:N]
		rand(Agents).status = I
		return Agents
	end
end

# ╔═╡ 1d0f8eb4-0a46-11eb-38e7-63ecbadbfa20
initialize(3, 10)

# ╔═╡ b5a88504-0a47-11eb-0eda-f125d419e909
position(a::AbstractAgent) = a.position # uncomment this line

# ╔═╡ 87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
color(a::AbstractAgent) = color(a.status) # uncomment this line

# ╔═╡ 1ccc961e-0a69-11eb-392b-915be07ef38d
function visualize(agents::Vector, L)
	p = plot(ratio=1)
	scatter!(p, make_tuple.(position.(agents)), color = color.(agents),
		label = nothing)
	outer_box = Shape([-L,L,L,-L],[-L,-L,L,L])
	plot!(outer_box, fillalpha = 0, label = nothing)
	return p
end

# ╔═╡ 1f96c80a-0a46-11eb-0690-f51c60e57c3f
let
	N = 20
	L = 10
	visualize(initialize(N, L), L) # uncomment this line!
end

# ╔═╡ 4f6ac130-5e90-11eb-03e0-2dbe0ba3349b
# functions for Agent type
begin
	function is_susceptible(agent::AbstractAgent)
		return agent.status == S
	end
	
	function is_infected(agent::AbstractAgent)
		return agent.status == I
	end
	
	function set_status!(agent::AbstractAgent, new_status::InfectionStatus)
		agent.status = new_status
	end
	
	function set_position!(agent::AbstractAgent, new_position::Coordinate)
		agent.position = new_position
	end
end

# ╔═╡ d1bcd5c4-0a4b-11eb-1218-7531e367a7ff
function interact!(agent::Agent, source::Agent, infection::CollisionInfectionRecovery)
	if is_susceptible(agent)
		if (agent.position == source.position && is_infected(source)
				&& rand() < infection.p_infection)
			set_status!(agent, I)
		end
	elseif is_infected(agent)
		if rand() < infection.p_recovery
			set_status!(agent, R)
		end
	end
end

# ╔═╡ 1b5e72c6-0a42-11eb-3884-a377c72270c7
mutable struct SocialAgent <: AbstractAgent 
	position::Coordinate
	status::InfectionStatus
	num_infected::Integer
	social_score::Float64
end

# ╔═╡ 40c1c1d6-0a69-11eb-3913-59e9b9ec4332
begin
	possible_social_scores = LinRange(0.1, 0.5, 10)
	
	function initialize_social(N::Number, L::Number)
		agents = [SocialAgent(rand_Coordinate(L), S, 0, rand(possible_social_scores))
			for _ in 1:N]
		set_status!(rand(agents), I)
		return agents
	end
end

# ╔═╡ b56ba420-0a41-11eb-266c-719d39580fa9
md"""
#### Exercise 4.2
Not all two agents who end up in the same grid point may actually interact in an infectious way -- they may just be passing by and do not create enough exposure for communicating the disease.

👉 Write a new `interact!` method on `SocialAgent` which adds together the social_scores for two agents and uses that as the probability that they interact in a risky way. Only if they interact in a risky way, the infection is transmitted with the usual probability.
"""

# ╔═╡ 465e918a-0a69-11eb-1b59-01150b4b0f36
function interact!(agent::SocialAgent, source::SocialAgent, 
		infection::CollisionInfectionRecovery)
	if is_susceptible(agent)
		if (agent.position == source.position && is_infected(source)
				&& rand() < (agent.social_score + source.social_score)
				&& rand() < infection.p_infection)
			set_status!(agent, I)
			source.num_infected += 1
		end
	elseif is_infected(agent)
		if rand() < infection.p_recovery
			set_status!(agent, R)
		end
	end
end

# ╔═╡ e5ef69a0-5ebb-11eb-009c-f9a6362864fa
let
	agent = Agent(Coordinate(0,0), S)
	source = Agent(Coordinate(0,0), I)
	
	interact!(agent, source, pandemic)
	
	(agent=agent, source=source)
end

# ╔═╡ 24fe0f1a-0a69-11eb-29fe-5fb6cbf281b8
function step!(agents::Vector{<:AbstractAgent}, L::Number, infection::AbstractInfection)
	source = rand(agents)
	move = rand(possible_moves)
	new_source_position = collide_boundary(source.position + move, L)
	set_position!(source, new_source_position)
	for agent in agents
		if agent !== source
			interact!(agent, source, infection)
		end
	end
	return agents
end

# ╔═╡ bda32d30-5ec8-11eb-2c5c-f35e2847f035
let
	agent = SocialAgent(Coordinate(0,0), S, 0, 0.1)
	source = SocialAgent(Coordinate(0,0), I, 0, 0.1)
	
	interact!(agent, source, pandemic)
	
	(agent=agent, source=source)
end

# ╔═╡ a885bf78-0a5c-11eb-2383-9d74c8765847
md"""
Make sure `step!`, `position`, `color`, work on the type `SocialAgent`. If `step!` takes an untyped first argument, it should work for both Agent and SocialAgent types without any changes. We actually only need to specialize `interact!` on SocialAgent.

#### Exercise 4.3
👉 Plot the SIR curves of the resulting simulation.

N = 50;
L = 40;
number of steps = 200

In each step call `step!` 50N times.
"""

# ╔═╡ b59de26c-0a41-11eb-2c67-b5f3c7780c91
md"""
#### Exercise 4.4
👉 Make a scatter plot showing each agent's `social_score` on one axis, and the `num_infected` from the simulation in the other axis. Run this simulation several times and comment on the results.
"""

# ╔═╡ 6a3464d0-5ecc-11eb-2eed-6fa78e0af4e9
md"""
`num_infected` is slightly higher for agents with higher social score
"""

# ╔═╡ b5b4d834-0a41-11eb-1b18-1bd626d18934
md"""
👉 Run a simulation for 100 steps, and then apply a "lockdown" where every agent's social score gets multiplied by 0.25, and then run a second simulation which runs on that same population from there.  What do you notice?  How does changing this factor form 0.25 to other numbers affect things?
"""

# ╔═╡ 05fc5634-09a0-11eb-038e-53d63c3edaf2
md"""
## **Exercise 5:** (Optional) _Effect of distancing_

We can use a variant of the above model to investigate the effect of the
mis-named "social distancing"  
(we want people to be *socially* close, but *physically* distant).

In this variant, we separate out the two effects "infection" and
"movement": an infected agent chooses a
neighbouring site, and if it finds a susceptible there then it infects it
with probability $p_I$. For simplicity we can ignore recovery.

Separately, an agent chooses a neighbouring site to move to,
and moves there with probability $p_M$ if the site is vacant. (Otherwise it
stays where it is.)

When $p_M = 0$, the agents cannot move, and hence are
completely quarantined in their original locations.

👉 How does the disease spread in this case?

"""

# ╔═╡ 24c2fb0c-0a42-11eb-1a1a-f1246f3420ff
mutable struct SocialDistancingAgent <: AbstractAgent 
	position::Coordinate
	status::InfectionStatus
end

# ╔═╡ eb837850-5f7b-11eb-169f-99bf7bcbbfe3
struct SocialDistancingInfection <: AbstractInfection
	p_infection::Float64
	p_move::Float64
	p_move_infected::Float64
end

# ╔═╡ 81e174d0-5f79-11eb-3274-b7659aaecee8
begin
	function initialize_social_distancing(N::Number, L::Number)
		agents = [SocialDistancingAgent(rand_Coordinate(L), S) for _ in 1:N]
		rand(agents).status = I
		return agents
	end
	
	function step!(agents::Vector{SocialDistancingAgent}, L::Number, 
			infection::SocialDistancingInfection)
		source = rand(agents)
		
		if is_infected(source)
			# try infect a neighbour
			infect_dir = rand(possible_moves)
			infect_position = collide_boundary(source.position + infect_dir, L)
			vunerable_idx = findfirst((position.(agents) .== (infect_position,))
			                          .& is_susceptible.(agents))
			if !isnothing(vunerable_idx) && rand() < infection.p_infection
				set_status!(agents[vunerable_idx], I)
			end
		end
		
		# make possible move
		move = rand(possible_moves)
		new_source_position = collide_boundary(source.position + move, L)
		move_probability = if is_infected(source)
			infection.p_move_infected
		else
			infection.p_move
		end
		if (!any(position.(agents) .== (new_source_position,))
			&& rand() < move_probability)
			set_position!(source, new_source_position)
		end
		
		return agents
	end
	
end

# ╔═╡ 3dc46af2-5ebb-11eb-0113-3727c0ca46a1
function sweep!(agents::Vector{<:AbstractAgent}, L::Number, 
		infection::AbstractInfection)
	for i in 1:length(agents)
		step!(agents, L::Number, infection)
	end
end

# ╔═╡ 36b50e30-5ebc-11eb-2a15-0fb63529952c
let
	L = 5
	agents = initialize(50, L)
	sweep!(agents, L, pandemic)
	visualize(agents, L)
end

# ╔═╡ 778c2490-0a62-11eb-2a6c-e7fab01c6822
let
	N = 50
	L = 40
	
	agents = initialize(N, L)
	plot_before = visualize(agents, L)
	for _ in 1:k_sweeps
		sweep!(agents, L, pandemic) 
	end
	plot_after = visualize(agents, L)
	
	plot(plot_before, plot_after)
end

# ╔═╡ 9125f340-5ebf-11eb-21b6-235752686e91
function simulation(N::Integer, L::Integer, T::Integer, infection::AbstractInfection)
	agents = initialize(N, L)
	
	S_counts = []
	I_counts = []
	R_counts = []
	
	for _ in 1:T
		sweep!(agents, L, infection)
		
		S_count = sum(is_susceptible.(agents))
		I_count = sum(is_infected.(agents))
		R_count = N - S_count - I_count
		push!(S_counts, S_count)
		push!(I_counts, I_count)
		push!(R_counts, R_count)
	end
	
	return (agents=agents, S=S_counts, I=I_counts, R=R_counts)
end

# ╔═╡ ef27de84-0a63-11eb-177f-2197439374c5
let
	N = 50
	L = 30
	
	sim = simulation(N, L, k_sweep_max, pandemic)
	
	result = plot(1:k_sweep_max, sim.S, ylim=(0, N),
		color=color(S), label="Susceptible")
	plot!(result, 1:k_sweep_max, sim.I, color=color(I), label="Infectious")
	plot!(result, 1:k_sweep_max, sim.R, color=color(R), label="Recovered")
end

# ╔═╡ 4d4548fe-0a66-11eb-375a-9313dc6c423d
let
	N = 100
	L = 20
	T = 3000
	
	sim_outbreak = simulation(N, L, T, causes_outbreak)
	sim_no_outbreak = simulation(N, L, T, does_not_cause_outbreak)
	
	left = plot(1:T, sim_outbreak.S, ylim=(0, N),
		color=color(S), label="Susceptible")
	plot!(left, 1:T, sim_outbreak.I, color=color(I), label="Infectious")
	plot!(left, 1:T, sim_outbreak.R, color=color(R), label="Recovered")
	
	right = plot(1:T, sim_no_outbreak.S, ylim=(0, N),
		color=color(S), label="Susceptible")
	plot!(right, 1:T, sim_no_outbreak.I, color=color(I), label="Infectious")
	plot!(right, 1:T, sim_no_outbreak.R, color=color(R), label="Recovered")
	
	plot(left, right)
end

# ╔═╡ 2b12a280-5ec2-11eb-2bce-f56bc3b1f0a9
simulations = let
	N = 50
	L = 40
	T = 10000
	sim_count = 50
	
	map(1:sim_count) do _
		simulation(N, L, T, pandemic)
	end
end

# ╔═╡ 601f4f54-0a45-11eb-3d6c-6b9ec75c6d4a
let
	p = plot()
	T = length(first(simulations).S)
	
	for sim in simulations
		plot!(p, 1:T, sim.S, alpha=.2, color=color(S), label=nothing)
		plot!(p, 1:T, sim.I, alpha=.2, color=color(I), label=nothing)
		plot!(p, 1:T, sim.R, alpha=.2, color=color(R), label=nothing)
	end
	
	avg_S = mean(getproperty.(simulations, :S))
	avg_I = mean(getproperty.(simulations, :I))
	avg_R = mean(getproperty.(simulations, :R))
	plot!(p, 1:T, avg_S, alpha=1, color=color(S), lw=3, label="S")
	plot!(p, 1:T, avg_I, alpha=1, color=color(I), lw=3, label="I")
	plot!(p, 1:T, avg_R, alpha=1, color=color(R), lw=3, label="R")
	
	p
end

# ╔═╡ faec52a8-0a60-11eb-082a-f5787b09d88c
let
	N = 50
    L = 40
	sim_steps = 10000
	
	sim_social_agents = initialize_social(N, L)
	for _ in 1:sim_steps
		sweep!(sim_social_agents, L, pandemic)
	end
	
	scatter(getproperty.(sim_social_agents, :social_score),
	    getproperty.(sim_social_agents, :num_infected), 
	    alpha = 0.3, label=nothing)
end

# ╔═╡ e5040c9e-0a65-11eb-0f45-270ab8161871
let
    N = 50
    L = 40

    x = initialize(N, L)
    
    # initialize to empty arrays
    Ss, Is, Rs = Int[], Int[], Int[]
    
    Tmax = 200
    
    @gif for t in 1:Tmax
        for i in 1:50N
            step!(x, L, pandemic)
        end

        S_count = sum(is_susceptible.(x))
		I_count = sum(is_infected.(x))
		R_count = N - S_count - I_count
		push!(Ss, S_count)
		push!(Is, I_count)
		push!(Rs, R_count)
        
        left = visualize(x, L)
    
        right = plot(xlim=(1,Tmax), ylim=(1,N), size=(600,300))
        plot!(right, 1:t, Ss, color=color(S), label="S")
        plot!(right, 1:t, Is, color=color(I), label="I")
        plot!(right, 1:t, Rs, color=color(R), label="R")
    
        plot(left, right)
    end
end

# ╔═╡ 1f172700-0a42-11eb-353b-87c0039788bd
let
    N = 50
    L = 40
    
	sim_social_agents = initialize_social(N, L)
    # initialize to empty arrays
    Ss, Is, Rs = Int[], Int[], Int[]
    
    Tmax = 200
    
    @gif for t in 1:Tmax
        for i in 1:50N
            step!(sim_social_agents, L, pandemic)
        end

        S_count = sum(is_susceptible.(sim_social_agents))
		I_count = sum(is_infected.(sim_social_agents))
		R_count = N - S_count - I_count
		push!(Ss, S_count)
		push!(Is, I_count)
		push!(Rs, R_count)
        
        left = visualize(sim_social_agents, L)
    
        right = plot(xlim=(1,Tmax), ylim=(1,N), size=(600,300))
        plot!(right, 1:t, Ss, color=color(S), label="S")
        plot!(right, 1:t, Is, color=color(I), label="I")
        plot!(right, 1:t, Rs, color=color(R), label="R")
    
        plot(left, right)
    end
end

# ╔═╡ a83c96e2-0a5a-11eb-0e58-15b5dda7d2d2
let
    N = 50
    L = 40
	infection = CollisionInfectionRecovery(0.5, 1E-5)
    
	sim_social_agents = initialize_social(N, L)
	sim_lockdown_agents = deepcopy(sim_social_agents)
    # initialize to empty arrays
    Ss1, Is1, Rs1 = Int[], Int[], Int[]
	Ss2, Is2, Rs2 = Int[], Int[], Int[]
    
    Tmax = 300
	t_lockdown = missing
    
    @gif for t in 1:Tmax
        for i in 1:50N
            step!(sim_social_agents, L, infection)
        end
		
		if ismissing(t_lockdown)
			sim_lockdown_agents = deepcopy(sim_social_agents)
		else
			for i in 1:50N
				step!(sim_lockdown_agents, L, infection)
			end
		end

        S_count_1 = sum(is_susceptible.(sim_social_agents))
		I_count_1 = sum(is_infected.(sim_social_agents))
		R_count_1 = N - S_count_1 - I_count_1
		push!(Ss1, S_count_1)
		push!(Is1, I_count_1)
		push!(Rs1, R_count_1)
    
        left = plot(xlim=(1,Tmax), ylim=(0,N), size=(600,300))
        plot!(left, 1:t, Ss1, color=color(S), label="S")
        plot!(left, 1:t, Is1, color=color(I), label="I")
        plot!(left, 1:t, Rs1, color=color(R), label="R")
		
		if I_count_1 >= 0.2 * N && ismissing(t_lockdown)
			t_lockdown = t
			for agent in sim_lockdown_agents
				agent.social_score *= 0.25
			end
		end
		
		S_count_2 = sum(is_susceptible.(sim_lockdown_agents))
		I_count_2 = sum(is_infected.(sim_lockdown_agents))
		R_count_2 = N - S_count_2 - I_count_2
		push!(Ss2, S_count_2)
		push!(Is2, I_count_2)
		push!(Rs2, R_count_2)
    
        right = plot(xlim=(1,Tmax), ylim=(0,N), size=(600,300))
        plot!(right, 1:t, Ss2, color=color(S), label="S")
        plot!(right, 1:t, Is2, color=color(I), label="I")
        plot!(right, 1:t, Rs2, color=color(R), label="R")
		
		if !ismissing(t_lockdown)
			plot!(right, [t_lockdown], seriestype = :vline, label=nothing)
		end
    
        plot(left, right)
    end
end

# ╔═╡ c7649966-0a41-11eb-3a3a-57363cea7b06
md"""
👉 Run the dynamics repeatedly, and plot the sites which become infected.
"""

# ╔═╡ 2635b574-0a42-11eb-1daa-971b2596ce44
let
	L = 20
	ρ = 0.2
	N = floor(ρ * L^2)
	
	x = initialize_social_distancing(N, L)
	inff = SocialDistancingInfection(0.5, 0.2, 0.001)
	T_max = 3000
	
	init_plot = visualize(x, L)
	S_counts = []
	I_counts = []
	
	for _ in 1:T_max
		sweep!(x, L, inff)
		S_count = sum(is_susceptible.(x))
		I_count = sum(is_infected.(x))
		push!(S_counts, S_count)
		push!(I_counts, I_count)
	end
	finish_plot = visualize(x, L)
	time_series = plot(xlim=(1, T_max), ylim=(0, N))
	plot!(time_series, 1:T_max, S_counts, color=color(S), lable="S")
	plot!(time_series, 1:T_max, I_counts, color=color(I), lable="I")
	
	l = @layout [a b; c]
	plot(init_plot, finish_plot, time_series, layout=l)
end

# ╔═╡ c77b085e-0a41-11eb-2fcb-534238cd3c49
md"""
👉 How does this change as you increase the *density*
    $\rho = N / (L^2)$ of agents?  Start with a small density.

This is basically the [**site percolation**](https://en.wikipedia.org/wiki/Percolation_theory) model.

When we increase $p_M$, we allow some local motion via random walks.
"""

# ╔═╡ 274fe006-0a42-11eb-1869-29193bb84957


# ╔═╡ c792374a-0a41-11eb-1e5b-89d9de2cf1f9
md"""
👉 Investigate how this leaky quarantine affects the infection dynamics with
different densities.

"""

# ╔═╡ d147f7f0-0a66-11eb-2877-2bc6680e396d


# ╔═╡ 0e6b60f6-0970-11eb-0485-636624a0f9d7
if student.name == "Jazzy Doe"
	md"""
	!!! danger "Before you submit"
	    Remember to fill in your **name** and **Kerberos ID** at the top of this notebook.
	"""
end

# ╔═╡ 0a82a274-0970-11eb-20a2-1f590be0e576
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 0aa666dc-0970-11eb-2568-99a6340c5ebd
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 8475baf0-0a63-11eb-1207-23f789d00802
hint(md"""
After every sweep, count the values $S$, $I$ and $R$ and push! them to 3 arrays. 
""")

# ╔═╡ f9b9e242-0a53-11eb-0c6a-4d9985ef1687
hint(md"""
```julia
let
	N = 50
	L = 40

	x = initialize(N, L)
	
	# initialize to empty arrays
	Ss, Is, Rs = Int[], Int[], Int[]
	
	Tmax = 200
	
	@gif for t in 1:Tmax
		for i in 1:50N
			step!(x, L, pandemic)
		end

		#... track S, I, R in Ss Is and Rs
		
		left = visualize(x, L)
	
		right = plot(xlim=(1,Tmax), ylim=(1,N), size=(600,300))
		plot!(right, 1:t, Ss, color=color(S), label="S")
		plot!(right, 1:t, Is, color=color(I), label="I")
		plot!(right, 1:t, Rs, color=color(R), label="R")
	
		plot(left, right)
	end
end
```
""")

# ╔═╡ 0acaf3b2-0970-11eb-1d98-bf9a718deaee
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ 0afab53c-0970-11eb-3e43-834513e4632e
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 0b21c93a-0970-11eb-33b0-550a39ba0843
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ 0b470eb6-0970-11eb-182f-7dfb4662f827
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]

# ╔═╡ 0b6b27ec-0970-11eb-20c2-89515ee3ab88
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ ec576da8-0a2c-11eb-1f7b-43dec5f6e4e7
let
	# we need to call Base.:+ instead of + to make Pluto understand what's going on
	# oops
	if @isdefined(Coordinate)
		result = Base.:+(Coordinate(3,4), Coordinate(10,10))

		if result isa Missing
			still_missing()
		elseif !(result isa Coordinate)
			keep_working(md"Make sure that your return a `Coordinate`. 🧭")
		elseif result.x != 13 || result.y != 14
			keep_working()
		else
			correct()
		end
	end
end

# ╔═╡ 0b901714-0970-11eb-0b6a-ebe739db8037
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ 66663fcc-0a58-11eb-3568-c1f990c75bf2
if !@isdefined(origin)
	not_defined(:origin)
else
	let
		if origin isa Missing
			still_missing()
		elseif !(origin isa Coordinate)
			keep_working(md"Make sure that `origin` is a `Coordinate`.")
		else
			if origin == Coordinate(0,0)
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ ad1253f8-0a34-11eb-265e-fffda9b6473f
if !@isdefined(make_tuple)
	not_defined(:make_tuple)
else
	let
		result = make_tuple(Coordinate(2,1))
		if result isa Missing
			still_missing()
		elseif !(result isa Tuple)
			keep_working(md"Make sure that you return a `Tuple`, like so: `return (1, 2)`.")
		else
			if result == (2,1)
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ 058e3f84-0a34-11eb-3f87-7118f14e107b
if !@isdefined(trajectory)
	not_defined(:trajectory)
else
	let
		c = Coordinate(8,8)
		t = trajectory(c, 100)
		
		if t isa Missing
			still_missing()
		elseif !(t isa Vector)
			keep_working(md"Make sure that you return a `Vector`.")
		elseif !(all(x -> isa(x, Coordinate), t))
			keep_working(md"Make sure that you return a `Vector` of `Coordinate`s.")
		else
			if length(t) != 100
				almost(md"Make sure that you return `n` elements.")
			elseif 1 < length(Set(t)) < 90
				correct()
			else
				keep_working(md"Are you sure that you chose each step randomly?")
			end
		end
	end
end

# ╔═╡ 4fac0f36-0a59-11eb-03d0-632dc9db063a
if !@isdefined(initialize)
	not_defined(:initialize)
else
	let
		N = 200
		result = initialize(N, 1)
		
		if result isa Missing
			still_missing()
		elseif !(result isa Vector) || length(result) != N
			keep_working(md"Make sure that you return a `Vector` of length `N`.")
		elseif any(e -> !(e isa Agent), result)
			keep_working(md"Make sure that you return a `Vector` of `Agent`s.")
		elseif length(Set(result)) != N
			keep_working(md"Make sure that you create `N` **new** `Agent`s. Do not repeat the same agent multiple times.")
		elseif sum(a -> a.status == S, result) == N-1 && sum(a -> a.status == I, result) == 1
			if 8 <= length(Set(a.position for a in result)) <= 9
				correct()
			else
				keep_working(md"The coordinates are not correctly sampled within the box.")
			end
		else
			keep_working(md"`N-1` agents should be Susceptible, 1 should be Infectious.")
		end
	end
end

# ╔═╡ d5cb6b2c-0a66-11eb-1aff-41d0e502d5e5
bigbreak = html"<br><br><br><br>";

# ╔═╡ fcafe15a-0a66-11eb-3ed7-3f8bbb8f5809
bigbreak

# ╔═╡ ed2d616c-0a66-11eb-1839-edf8d15cf82a
bigbreak

# ╔═╡ e84e0944-0a66-11eb-12d3-e12ae10f39a6
bigbreak

# ╔═╡ e0baf75a-0a66-11eb-0562-938b64a473ac
bigbreak

# ╔═╡ Cell order:
# ╟─19fe1ee8-0970-11eb-2a0d-7d25e7d773c6
# ╟─1bba5552-0970-11eb-1b9a-87eeee0ecc36
# ╟─49567f8e-09a2-11eb-34c1-bb5c0b642fe8
# ╟─181e156c-0970-11eb-0b77-49b143cc0fc0
# ╠═1f299cc6-0970-11eb-195b-3f951f92ceeb
# ╟─2848996c-0970-11eb-19eb-c719d797c322
# ╠═2b37ca3a-0970-11eb-3c3d-4f788b411d1a
# ╠═2dcb18d0-0970-11eb-048a-c1734c6db842
# ╟─69d12414-0952-11eb-213d-2f9e13e4b418
# ╟─fcafe15a-0a66-11eb-3ed7-3f8bbb8f5809
# ╟─3e54848a-0954-11eb-3948-f9d7f07f5e23
# ╟─3e623454-0954-11eb-03f9-79c873d069a0
# ╠═0ebd35c8-0972-11eb-2e67-698fd2d311d2
# ╟─027a5f48-0a44-11eb-1fbf-a94d02d0b8e3
# ╠═b2f90634-0a68-11eb-1618-0b42f956b5a7
# ╟─66663fcc-0a58-11eb-3568-c1f990c75bf2
# ╟─3e858990-0954-11eb-3d10-d10175d8ca1c
# ╠═189bafac-0972-11eb-1893-094691b2073c
# ╟─ad1253f8-0a34-11eb-265e-fffda9b6473f
# ╟─73ed1384-0a29-11eb-06bd-d3c441b8a5fc
# ╠═96707ef0-0a29-11eb-1a3e-6bcdfb7897eb
# ╠═b0337d24-0a29-11eb-1fab-876a87c0973f
# ╟─9c9f53b2-09ea-11eb-0cda-639764250cee
# ╠═e24d5796-0a68-11eb-23bb-d55d206f3c40
# ╠═ec8e4daa-0a2c-11eb-20e1-c5957e1feba3
# ╟─e144e9d0-0a2d-11eb-016e-0b79eba4b2bb
# ╟─ec576da8-0a2c-11eb-1f7b-43dec5f6e4e7
# ╟─71c358d8-0a2f-11eb-29e1-57ff1915e84a
# ╠═5278e232-0972-11eb-19ff-a1a195127297
# ╟─71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
# ╠═69151ce6-0aeb-11eb-3a53-290ba46add96
# ╟─3eb46664-0954-11eb-31d8-d9c0b74cf62b
# ╠═edf86a0e-0a68-11eb-2ad3-dbf020037019
# ╠═44107808-096c-11eb-013f-7b79a90aaac8
# ╟─87ea0868-0a35-11eb-0ea8-63e27d8eda6e
# ╟─058e3f84-0a34-11eb-3f87-7118f14e107b
# ╠═478309f4-0a31-11eb-08ea-ade1755f53e0
# ╠═51788e8e-0a31-11eb-027e-fd9b0dc716b5
# ╟─3ebd436c-0954-11eb-170d-1d468e2c7a37
# ╠═dcefc6fe-0a3f-11eb-2a96-ddf9c0891873
# ╟─b4d5da4a-09a0-11eb-1949-a5807c11c76c
# ╠═0237ebac-0a69-11eb-2272-35ea4e845d84
# ╠═ad832360-0a40-11eb-2857-e7f0350f3b12
# ╟─b4ed2362-09a0-11eb-0be9-99c91623b28f
# ╠═0665aa3e-0a69-11eb-2b5d-cd718e3c7432
# ╟─ed2d616c-0a66-11eb-1839-edf8d15cf82a
# ╟─3ed06c80-0954-11eb-3aee-69e4ccdc4f9d
# ╠═35537320-0a47-11eb-12b3-931310f18dec
# ╠═cf2f3b98-09a0-11eb-032a-49cc8c15e89c
# ╟─814e888a-0954-11eb-02e5-0964c7410d30
# ╠═0cfae7ba-0a69-11eb-3690-d973d70e47f4
# ╠═1d0f8eb4-0a46-11eb-38e7-63ecbadbfa20
# ╟─4fac0f36-0a59-11eb-03d0-632dc9db063a
# ╠═e0b0880c-0a47-11eb-0db2-f760bbbf9c11
# ╠═b5a88504-0a47-11eb-0eda-f125d419e909
# ╠═87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
# ╟─49fa8092-0a43-11eb-0ba9-65785ac6a42f
# ╠═1ccc961e-0a69-11eb-392b-915be07ef38d
# ╠═1f96c80a-0a46-11eb-0690-f51c60e57c3f
# ╟─f953e06e-099f-11eb-3549-73f59fed8132
# ╠═e6dd8258-0a4b-11eb-24cb-fd5b3554381b
# ╠═de88b530-0a4b-11eb-05f7-85171594a8e8
# ╟─80f39140-0aef-11eb-21f7-b788c5eab5c9
# ╠═4f6ac130-5e90-11eb-03e0-2dbe0ba3349b
# ╠═d1bcd5c4-0a4b-11eb-1218-7531e367a7ff
# ╠═e5ef69a0-5ebb-11eb-009c-f9a6362864fa
# ╟─34778744-0a5f-11eb-22b6-abe8b8fc34fd
# ╠═24fe0f1a-0a69-11eb-29fe-5fb6cbf281b8
# ╠═36b50e30-5ebc-11eb-2a15-0fb63529952c
# ╟─1fc3271e-0a45-11eb-0e8d-0fd355f5846b
# ╟─18552c36-0a4d-11eb-19a0-d7d26897af36
# ╠═4e7fd58a-0a62-11eb-1596-c717e0845bd5
# ╠═3dc46af2-5ebb-11eb-0113-3727c0ca46a1
# ╠═778c2490-0a62-11eb-2a6c-e7fab01c6822
# ╟─e964c7f0-0a61-11eb-1782-0b728fab1db0
# ╠═4d83dbd0-0a63-11eb-0bdc-757f0e721221
# ╠═9125f340-5ebf-11eb-21b6-235752686e91
# ╠═ef27de84-0a63-11eb-177f-2197439374c5
# ╟─8475baf0-0a63-11eb-1207-23f789d00802
# ╟─201a3810-0a45-11eb-0ac9-a90419d0b723
# ╠═e5040c9e-0a65-11eb-0f45-270ab8161871
# ╟─f9b9e242-0a53-11eb-0c6a-4d9985ef1687
# ╟─2031246c-0a45-11eb-18d3-573f336044bf
# ╠═63dd9478-0a45-11eb-2340-6d3d00f9bb5f
# ╠═269955e4-0a46-11eb-02cc-1946dc918bfa
# ╠═4d4548fe-0a66-11eb-375a-9313dc6c423d
# ╟─20477a78-0a45-11eb-39d7-93918212a8bc
# ╠═2b12a280-5ec2-11eb-2bce-f56bc3b1f0a9
# ╠═601f4f54-0a45-11eb-3d6c-6b9ec75c6d4a
# ╠═b1b1afda-0a66-11eb-2988-752405815f95
# ╟─e84e0944-0a66-11eb-12d3-e12ae10f39a6
# ╟─05c80a0c-09a0-11eb-04dc-f97e306f1603
# ╟─b53d5608-0a41-11eb-2325-016636a22f71
# ╠═1b5e72c6-0a42-11eb-3884-a377c72270c7
# ╟─c704ea4c-0aec-11eb-2f2c-859c954aa520
# ╠═e97e39aa-0a5d-11eb-3d5f-f90a0acfe5a2
# ╟─b554b654-0a41-11eb-0e0d-e57ff68ced33
# ╠═40c1c1d6-0a69-11eb-3913-59e9b9ec4332
# ╟─18ac9926-0aed-11eb-034f-e9849b71c9ac
# ╠═e73f0f92-5ec5-11eb-28f8-4da4202b98a7
# ╟─b56ba420-0a41-11eb-266c-719d39580fa9
# ╠═465e918a-0a69-11eb-1b59-01150b4b0f36
# ╠═bda32d30-5ec8-11eb-2c5c-f35e2847f035
# ╟─a885bf78-0a5c-11eb-2383-9d74c8765847
# ╠═1f172700-0a42-11eb-353b-87c0039788bd
# ╟─b59de26c-0a41-11eb-2c67-b5f3c7780c91
# ╠═faec52a8-0a60-11eb-082a-f5787b09d88c
# ╠═6a3464d0-5ecc-11eb-2eed-6fa78e0af4e9
# ╟─b5b4d834-0a41-11eb-1b18-1bd626d18934
# ╠═a83c96e2-0a5a-11eb-0e58-15b5dda7d2d2
# ╟─05fc5634-09a0-11eb-038e-53d63c3edaf2
# ╠═24c2fb0c-0a42-11eb-1a1a-f1246f3420ff
# ╠═eb837850-5f7b-11eb-169f-99bf7bcbbfe3
# ╠═81e174d0-5f79-11eb-3274-b7659aaecee8
# ╟─c7649966-0a41-11eb-3a3a-57363cea7b06
# ╠═2635b574-0a42-11eb-1daa-971b2596ce44
# ╟─c77b085e-0a41-11eb-2fcb-534238cd3c49
# ╠═274fe006-0a42-11eb-1869-29193bb84957
# ╟─c792374a-0a41-11eb-1e5b-89d9de2cf1f9
# ╠═d147f7f0-0a66-11eb-2877-2bc6680e396d
# ╟─e0baf75a-0a66-11eb-0562-938b64a473ac
# ╟─0e6b60f6-0970-11eb-0485-636624a0f9d7
# ╟─0a82a274-0970-11eb-20a2-1f590be0e576
# ╟─0aa666dc-0970-11eb-2568-99a6340c5ebd
# ╟─0acaf3b2-0970-11eb-1d98-bf9a718deaee
# ╟─0afab53c-0970-11eb-3e43-834513e4632e
# ╟─0b21c93a-0970-11eb-33b0-550a39ba0843
# ╟─0b470eb6-0970-11eb-182f-7dfb4662f827
# ╟─0b6b27ec-0970-11eb-20c2-89515ee3ab88
# ╟─0b901714-0970-11eb-0b6a-ebe739db8037
# ╟─d5cb6b2c-0a66-11eb-1aff-41d0e502d5e5
