### A Pluto.jl notebook ###
# v0.19.11

#> [frontmatter]
#> author = "Martin Scheidt, ORCID: 0000-0002-9384-8945"
#> title = "How to use TrainRuns.jl - A basic tutorial."
#> date = "2022-09-21"
#> license = "ISC"

using Markdown
using InteractiveUtils

# ╔═╡ 6c9651f1-d3a8-4e0b-9237-47c558e5f6d9
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = true
#=╠═╡
begin
	import Pkg
	Pkg.add("TrainRuns") # main package to calculate train runs
	Pkg.add("PlutoUI")   # figures in Pluto Notebook
	Pkg.add("Makie")     # visualization
	Pkg.add("CairoMakie")# visualization
end
  ╠═╡ =#

# ╔═╡ c7acab7d-5f7f-4d36-802a-a92c40caa05c
using PlutoUI; TableOfContents()

# ╔═╡ 99d71c61-ad79-49c6-a010-2ab7b47ca4fc
using TrainRuns

# ╔═╡ 18c765e3-0e89-47b5-8684-5b32b9c4f4b7
using CairoMakie

# ╔═╡ ca7a34a8-7313-421f-9234-b78a78cb314c
using Makie.GeometryBasics

# ╔═╡ 5250c2f4-28a7-11ed-2199-499874015c33
md"# How to use _TrainRuns.jl_ - A basic tutorial."

# ╔═╡ 7cf700ff-ce6a-4208-af61-d1c56a6bbbd0
md"
> This work is under ISC License.
>
> Copyright 2022 Martin Scheidt, ORCID: [0000-0002-9384-8945](https://orcid.org/0000-0002-9384-8945).
>
> Permission to use, copy, modify, and/or distribute this file for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies."

# ╔═╡ 554d7352-2a63-4af8-850a-05edfa722cab
md"## Introduction"

# ╔═╡ 855906ad-72ab-4f2b-8eaa-610910119bb8
md"Besides _TrainRuns.jl_, we will need data for trains and running paths. You might find helpful rolling stock data at [railtoolkit/rolling-stock-data](https://github.com/railtoolkit/rolling-stock-data), which can be composed into a train. Path data is harder to come by: OpenStreetMap might be a good starting point.

We will use predefined data as a showcase in this Tutorial with the following files:"

# ╔═╡ 8e8a50a0-c06a-4bae-8381-554b27ee6d30
readdir("data")

# ╔═╡ cf60bbfe-4bfa-4db8-8a7d-71ae8b01321e
md"As a prerequisite, we need to install a few packages:"

# ╔═╡ 37fcf779-f387-47a2-83a0-e19520bbf50d
md"We need _PlutoUI_ to run this Pluto Notebook with figures and a Table of Contents:"

# ╔═╡ d65a0dc3-05b7-413a-87da-210d77cf81e6


# ╔═╡ 09f65546-8b5b-4245-a1ae-5fb94bc1fa1c
md"## Loading Train data"

# ╔═╡ b2a62d19-9df3-4996-adef-2abb7d51dfa7
md"To calculate train runs and work with data we need to load the package:"

# ╔═╡ 4b59e46f-ec82-44fe-b6ad-fc5877344e1e
md"Next we can load data for a train and a path. Currently, the supported file format is a YAML file in the [railtoolkit/schema](https://github.com/railtoolkit/schema). The schema provides a simple data structure. The following (non-functional) example demonstrates the structure of a train:"

# ╔═╡ 08ee1a7c-aa68-4ff1-ba1e-0e96384e2477
md"""
```YAML
%YAML 1.2
---
schema: https://railtoolkit.org/schema/rolling-stock.json
schema_version: "2022.05"
trains:
  - name: "example"
    id: "1"
    formation: [veh1,veh2,veh2]

vehicles:
  - name: "loco"
    id: "veh1"
    vehicle_type: traction
    length: 20
    mass: 100
    ...
  - name: "passenger car"
    id: "veh2"
    vehicle_type: passenger
    length: 30
    mass: 40
    ...
```
"""

# ╔═╡ b0df2dc2-8d47-4e7d-b85a-9944b9a68970
md"We can load a train via the YAML file and the _Train_ type constructor:"

# ╔═╡ c787d222-e326-4f7f-a6b8-8e8fc9a1c272
freight_train = Train("data/freight_train.yaml")

# ╔═╡ 767acc0e-50ec-425a-ab68-b649c90e135c
md"... and a second train:"

# ╔═╡ 8fbf1630-d661-4294-9f92-f8718f9818c9
passenger_train = Train("data/local_train.yaml")

# ╔═╡ 408584b4-1f15-47c5-9ba2-b051b3fc4ba1


# ╔═╡ c6f03bc1-dcd7-40af-b7b7-b9d59a27f58b
md"## Loading path data"

# ╔═╡ 41b7e28f-e32b-485c-b86d-dff7ce548b1d
md"The [railtoolkit/schema](https://github.com/railtoolkit/schema) also provides a schema for path:"

# ╔═╡ 2f4915b4-7150-4cee-ba62-9df438fb23b9
md"""
```YAML
%YAML 1.2
---
schema: https://railtoolkit.org/schema/running-path.json
schema_version: "2022.05"
paths:
  - name: "example"
    id: simple
    points_of_interest:
      # [ station in m,                name,   front or rear ]
      - [      5000.00,            "label1",           front ]
      - [      7500.00,            "label2",            rear ]
      ...
    characteristic_sections:
      # [ station in m, speed limit in km/h, resistance in ‰ ]
      - [          0.0,                 160,            0.00 ]
      ...
      - [      10000.0,                 160,            0.00 ]
```
"""

# ╔═╡ 70bc0080-5081-46aa-ba33-5af9e99c3403
md"It is assumed that a train run will start at the first Characteristic Section and end at the last Characteristic Section. If the train needs an intermediate stop, you will have to split the path into two separate ones.
The Points of Interest can be used to compute running time values at the specified location either for the front or the rear of the train."

# ╔═╡ a5e53ff9-b7db-42da-af37-8cbcdddb28c3
md"We can load a path via the YAML file and the _Path_ type constructor:"

# ╔═╡ 61a19dbd-6b57-4a90-ba91-25fbf43052af
simple_path = Path("data/simple_path.yaml")

# ╔═╡ 87ca3f56-7e80-4481-9e36-985b4406e1b4


# ╔═╡ 7f8d3ef6-b5bc-416f-84e1-33b6dd125190
md"## Calculating running times"

# ╔═╡ 5ee86537-0bdf-4d20-8617-06a9ae39c929
md"We now can calculate running times with the two trains and the path previously loaded with _trainrun()_:"

# ╔═╡ 7d514a09-e728-46c1-a3d4-12af8af48ac1
trainrun(freight_train, simple_path)

# ╔═╡ 936b95f0-c2ea-4612-82d0-7af3ff7b8d1d
md"The return value is a _DataFrame_ with a single value for the total running time. It seems over the top to return a _DataFrame_ for a single value, but this format was chosen to have a unified return value where more values are asked for."

# ╔═╡ 09334647-ff58-441b-bc5e-aaf8f58955fa
md"We can access the value in the _DataFrame_ directly with `[row, column]`:"

# ╔═╡ 69694541-950b-4d24-b85a-a82a13673cf2
trainrun(passenger_train, simple_path)[end,:t]

# ╔═╡ db687961-99db-4b47-9520-98092fc25693
md"All units of the values follow the SI-system - accordingly, the time is in seconds."

# ╔═╡ 4b27f5b5-b4db-478a-864f-afafc693c850


# ╔═╡ f7fe1256-6f13-4d77-8667-c13751226b36
md"## Calculating Points of Interest"

# ╔═╡ a0062836-3018-439d-b05a-2376f121b2ed
md"_Points of Interest_ are points along the path where we want exact time, speed, and position. They can be calculated for the front or the rear of the train and have to be specified with a _label_ in the path file. To instruct the function to return the _Points of Interest_, we must change the settings:"

# ╔═╡ bcaffeeb-c8b4-41b3-af0f-134c0e78f9b9
settings_poi = Settings(outputDetail=:points_of_interest)

# ╔═╡ dbcc00c1-b6e6-42e6-b782-aa715da4fb45
md"Now the _DataFrame_ returns significantly more data:"

# ╔═╡ 698606b3-45e5-432d-8555-64d7f1a1ad9c
trainrun(freight_train, simple_path, settings_poi)

# ╔═╡ b3aa1e53-dc35-410c-92d4-992897bd0d86


# ╔═╡ aade6a3a-1a80-4320-baaf-e83199a5873b
md"## Blocking time"

# ╔═╡ 782afb46-8292-4041-b6bf-f445ec222c67
md"Blocking time is the time a train exclusivly occupies a block. The next train can follow after that time. The blocking time is vidualizte in a time-distance-diagram as follows:"

# ╔═╡ d057f931-fd1f-447b-8bbe-fc91875250f6
md"""$(LocalResource("figures/blocking_time_light.png"))"""

# ╔═╡ f96c348f-352f-4c0b-9597-fb959a5e5131
md"If we want to calculate the blocking time for a train run, we can add the distance of each element of a block in the list of _Points of Interest_ in the path description.

Consider the following infrastructure with two blocks. The first block starts at the main signal _0_ and ends at the main signal _1_. The second block starts at the main signal _1_ and ends at the main signal _2_:"

# ╔═╡ 967542e7-a8cf-45b0-bfc6-23af73b756bb
md"""$(LocalResource("figures/infra_light.png"))"""

# ╔═╡ bfc0e281-4d55-4840-a56b-b4c36832d7fa
md"The infrastructure will translate into the following _Points of Interest_ with made up distances and meaningful labels:"

# ╔═╡ be9818f4-178a-4157-a12c-08502b1b8180
println(String(read("data/block_sections.yaml")))

# ╔═╡ 8cb842fb-7e22-4fda-8414-79419d6027a5
md"First, we need to load the _Path_ with the _Points of Interest_:"

# ╔═╡ 2a95f4b6-b91f-46e8-a780-21039bf6a698
block_sections = Path("data/block_sections.yaml")

# ╔═╡ 2f3340ee-e493-46aa-a044-095832bc297c
md"Then, we can calculate the passing of the train at these points:"

# ╔═╡ 5ff7f35f-5c0e-4f8f-b34d-1b56fa0b4345
run_block = trainrun(passenger_train, block_sections, settings_poi)

# ╔═╡ bfa544d5-cae5-4195-8e78-20479d8bbbb5
md"With the _DataFrame_ above we can filter the times we need for the occupation time of Block A (from signal 0 to signal 1).

The starting time of the occupation begins with the view point:"

# ╔═╡ 8c044304-e067-46fd-ae04-2bccf6ceafd6
start_block_A = filter(row -> any(occursin.(["0:view point"], row.label)), run_block)[1,:t]

# ╔═╡ 247477d9-6a3d-44f3-b9a0-854cb9abad3b
md"The trains enters the block at the first main signal (0) and leaves it at the second main signal (1):"

# ╔═╡ e356bb7b-ae58-4acc-b343-9c010cb014d2
ingress_block_A = filter(row -> any(occursin.(["0:main signal"], row.label)), run_block)[1,:s]

# ╔═╡ 30fdadea-198f-4327-ba48-d370210d462e
egress_block_A = filter(row -> any(occursin.(["1:main signal"], row.label)), run_block)[1,:s]

# ╔═╡ f3743920-b394-45ef-907a-48a1c3f57018
md"The occupation time ends when the train clears the block at the clearing point:"

# ╔═╡ 5e8b1b7c-29f4-4e10-891c-9ed09e58b04b
end_block_A = filter(row -> any(occursin.(["1:clearing point"], row.label)), run_block)[1,:t]

# ╔═╡ 09abccd2-6c8c-4aaa-ba00-2672ffb0e960
md"With the filtered data we can calculate the occupation time and the block length:"

# ╔═╡ b88936da-4c40-4b45-a7c1-bd74d72b8478
blocking_time_A = end_block_A - start_block_A

# ╔═╡ 76a24a28-4ae1-42c9-bb61-b0edcd0c7565
block_length_A = egress_block_A - ingress_block_A

# ╔═╡ fcfd8238-9bbc-45c1-9955-d5ad0adaac40
md"And we can do the same for Block B (from signal 1 to signal 2):"

# ╔═╡ b65e4278-1fe1-458e-8c9b-d79caf9b83eb
start_block_B = filter(row -> row.label == "1:view point", run_block)[1,:t]

# ╔═╡ a4d4e1d3-0f7b-4fbc-a173-ea9e1ee121bb
ingress_block_B = filter(row -> row.label == "1:main signal", run_block)[1,:s]

# ╔═╡ 30c676d2-fbe2-402e-b443-a2b547ada139
end_block_B = filter(row -> row.label == "2:clearing point", run_block)[1,:t]

# ╔═╡ 83886f8d-8dad-4d70-b3d6-236ab1e3835e
egress_block_B = filter(row -> row.label == "2:main signal", run_block)[1,:s]

# ╔═╡ 390f7bb4-55d8-44ba-b229-7d66ac4fbe4e
blocking_time_B = end_block_B - start_block_B

# ╔═╡ f8d3a67e-d3c5-49e7-9b93-4b31961e2e14
block_length_B = egress_block_B - ingress_block_B

# ╔═╡ 284ad6b5-0a55-45ac-b4d6-864734f818c7
md"Note: For the complete blocking time we should add a time for clearing the signal and a release time. But for this example we will waive."

# ╔═╡ 7b4a8c04-91c8-46e7-b78b-117abe1f269a


# ╔═╡ 8b75a89f-d2ec-472d-8842-da7975f6e2b3
md"## Visualization"

# ╔═╡ 7721656e-74ea-4ae0-a17c-8f13e99217a5
md"If we want not only to calculate running times and blocking times but also plot them, we need some additional packages for plotting:"

# ╔═╡ 392abdee-54ed-4c50-913e-b17d518c10fe
md"It is necessary to have enough data points so that the plot covers the complete train run and has a relatively smooth curve for plotting.

To achieve this, we change the settings of the _outputDetails_ to give us the `driving_course` for all the data points:"

# ╔═╡ dec1445f-e27f-4631-8bba-3d79a84ae902
settings_all = Settings(outputDetail=:driving_course)

# ╔═╡ 8dbdf7ae-6a75-46d6-88e7-16e57339bb18
md"... and than execute the run:"

# ╔═╡ debf8d0e-7ebe-4bb0-991b-f1da7973e361
run = trainrun(passenger_train, block_sections, settings_all)

# ╔═╡ ea10b479-5468-4390-aad7-00b8c209fb5e
md"We now need to create a canvas to get a plot. The package _Makie_ provides the canvas. Please refer to its [documentation](https://docs.juliahub.com/MakieGallery/) for how it works and is to be used. The following code will produce a figure with two but still empty diagrams. A distance-speed-diagram (sv\_diagram) on top and a distance-time-diagram (st\_diagram) below:"

# ╔═╡ 7b964da0-a9c2-4a56-bb7a-655873ae1b98
begin
	# new but empty figure
	fig = Figure()
	#  adding distance speed axis to the figure
    sv_diagram = Axis(fig[1,1],
        # title = "s-v-diagram",
        xlabel = "distance in km",
        xaxisposition =  :top,
        xticks = 0:2:run.s[end]/1000,
        xticksmirrored = true,
        ylabel = "speed in km/h",
        ytickformat = "{:.1f}",
        yticks = 0:20:maximum(run.v)*3.6+20,
        yticksmirrored = true
    )
	# adding distance time axis to the figure
    st_diagram = Axis(fig[2:4,1],
        # title = "s-t-diagram",
        xlabel = "distance in km",
        xaxisposition =  :bottom,
        xticks = 0:2:run.s[end]/1000,
        xticksmirrored = true,
        ylabel = "time in min",
        ytickformat = "{:.1f}",
        yticksmirrored = true,
        yreversed = true
    )
    linkxaxes!(sv_diagram, st_diagram)
end

# ╔═╡ c99a124b-ea0b-4cc5-b4ec-ec41e7f9a76c
md"We now can add our data from run converted in the right dimensions to both diagrams:"

# ╔═╡ 5bbb5d67-ac9f-447c-b6e9-ac3c8aae5e8d
lines!(sv_diagram, run.s./1000, run.v.*3.6, color = :blue)

# ╔═╡ 8b9d4401-1566-4475-8082-0ac06f0b98cb
lines!(st_diagram, run.s./1000, run.t./60, color = :blue)

# ╔═╡ 0de40dfb-5adb-421c-a3b5-95de4c0d6aee
md"We must recall our figure variable to show the figure:"

# ╔═╡ fdab4ca9-5434-4f1a-a3ae-0519aeec4e8e
fig # recall the figure for plotting

# ╔═╡ 404b660e-9668-448b-bf6d-582cac5f9811
md"We need rectangles to add blocking times. Graphical rectangles are provided by:"

# ╔═╡ 89edb5e9-16e3-4e64-b616-573fa5983c7e
md"""
Now, we can draw a rectangle with the origin at (s,t) and a width/height as a vector (+s,+t):
```Julia
Rect(s,t,+s,+t)
```

The following commands will create geometric rectangles for both blocks (A and B):
"""

# ╔═╡ f75158da-f80f-4c09-9a3b-ff1716ba033c
block_A = Rect(
	ingress_block_A/1000, start_block_A/60, # origin
	block_length_A/1000, blocking_time_A/60 # width and height
)

# ╔═╡ 3dd2b53f-1784-47af-b710-4c31991682c2
block_B = Rect(
	ingress_block_B/1000, start_block_B/60,
	block_length_B/1000, blocking_time_B/60
)

# ╔═╡ 16d61597-aeea-40a9-98fa-4d3f42228996
md"We now can add the rectangles to plot and update the figure:"

# ╔═╡ f193e26b-4622-4b7d-a72d-9cd4f5fb94d5
poly!(st_diagram, [block_A, block_B], color=:transparent, strokecolor = :blue, strokewidth = 1)

# ╔═╡ 05d86af7-d4e6-4a56-90b0-85dd04c15091
fig # recall the figure for plotting

# ╔═╡ 3007f345-7095-45b8-8dec-e649fefd7936


# ╔═╡ ea7a9d5c-873d-437e-b7a9-a1f4ce45e0f2
md"## Real world example"

# ╔═╡ 7f64d35c-6bfe-41f2-9c79-b2fe3c134885
md"The following example summarizes the usage with an example of different speed limits and track resistances. For the path, we use the [Görlitz–Dresden railway](https://en.wikipedia.org/wiki/Görlitz–Dresden_railway) and the trains from before.
![](https://upload.wikimedia.org/wikipedia/commons/a/a0/Map-of-6212-G%C3%B6rlitz-Dresden.png)
"

# ╔═╡ 69fc9ec5-5b2d-4f1e-8799-b483669e5c07
realworld_path = Path("data/realworld_path.yaml")

# ╔═╡ a05e1274-17e8-4def-88cb-2806bc0f50e4
run_realworld_passenger = trainrun(passenger_train, realworld_path, settings_all)

# ╔═╡ 31e84d61-61b5-446a-b263-b01d4612a1aa
run_realworld_freight = trainrun(freight_train, realworld_path, settings_all)

# ╔═╡ 8e9716b9-44cf-496e-b9ec-d3e978cb064a
begin
	# new but empty figure
	fig_realworld = Figure()
	#  adding distance speed axis to the figure
    sv_diagram_realworld = Axis(fig_realworld[1,1],
        # title = "s-v-diagram",
        xlabel = "distance in km",
        xaxisposition =  :top,
        xticks = 0:10:run_realworld_passenger.s[end]/1000,
        xticksmirrored = true,
        ylabel = "speed in km/h",
        ytickformat = "{:.1f}",
        yticks = 0:20:maximum(run_realworld_passenger.v)*3.6+20,
        yticksmirrored = true
    )
	# adding distance time axis to the figure
    st_diagram_realworld = Axis(fig_realworld[2:4,1],
        # title = "s-t-diagram",
        xlabel = "distance in km",
        xaxisposition =  :bottom,
        xticks = 0:10:run_realworld_passenger.s[end]/1000,
        xticksmirrored = true,
        ylabel = "time in min",
        ytickformat = "{:.1f}",
        yticksmirrored = true,
        yreversed = true
    )
    linkxaxes!(sv_diagram_realworld, st_diagram_realworld)
end

# ╔═╡ 6936c303-df51-496c-ab5d-c56c9f0c29e6
begin
	lines!(
		sv_diagram_realworld,
		run_realworld_passenger.s./1000,
		run_realworld_passenger.v.*3.6,
		color = :blue
	)
	lines!(
		st_diagram_realworld,
		run_realworld_passenger.s./1000,
		run_realworld_passenger.t./60,
		color = :blue,
		label = "passenger train")
	lines!(
		sv_diagram_realworld,
		run_realworld_freight.s./1000,
		run_realworld_freight.v.*3.6,
		color = :red
	)
	lines!(
		st_diagram_realworld,
		run_realworld_freight.s./1000,
		run_realworld_freight.t./60,
		color = :red,
		label = "freight train"
	)
end

# ╔═╡ b1dc91ee-979d-4c70-89e8-6cc413177377
fig_realworld

# ╔═╡ Cell order:
# ╟─5250c2f4-28a7-11ed-2199-499874015c33
# ╟─7cf700ff-ce6a-4208-af61-d1c56a6bbbd0
# ╟─554d7352-2a63-4af8-850a-05edfa722cab
# ╟─855906ad-72ab-4f2b-8eaa-610910119bb8
# ╠═8e8a50a0-c06a-4bae-8381-554b27ee6d30
# ╟─cf60bbfe-4bfa-4db8-8a7d-71ae8b01321e
# ╠═6c9651f1-d3a8-4e0b-9237-47c558e5f6d9
# ╟─37fcf779-f387-47a2-83a0-e19520bbf50d
# ╠═c7acab7d-5f7f-4d36-802a-a92c40caa05c
# ╟─d65a0dc3-05b7-413a-87da-210d77cf81e6
# ╟─09f65546-8b5b-4245-a1ae-5fb94bc1fa1c
# ╟─b2a62d19-9df3-4996-adef-2abb7d51dfa7
# ╠═99d71c61-ad79-49c6-a010-2ab7b47ca4fc
# ╟─4b59e46f-ec82-44fe-b6ad-fc5877344e1e
# ╟─08ee1a7c-aa68-4ff1-ba1e-0e96384e2477
# ╟─b0df2dc2-8d47-4e7d-b85a-9944b9a68970
# ╠═c787d222-e326-4f7f-a6b8-8e8fc9a1c272
# ╟─767acc0e-50ec-425a-ab68-b649c90e135c
# ╠═8fbf1630-d661-4294-9f92-f8718f9818c9
# ╟─408584b4-1f15-47c5-9ba2-b051b3fc4ba1
# ╟─c6f03bc1-dcd7-40af-b7b7-b9d59a27f58b
# ╟─41b7e28f-e32b-485c-b86d-dff7ce548b1d
# ╟─2f4915b4-7150-4cee-ba62-9df438fb23b9
# ╟─70bc0080-5081-46aa-ba33-5af9e99c3403
# ╟─a5e53ff9-b7db-42da-af37-8cbcdddb28c3
# ╠═61a19dbd-6b57-4a90-ba91-25fbf43052af
# ╟─87ca3f56-7e80-4481-9e36-985b4406e1b4
# ╟─7f8d3ef6-b5bc-416f-84e1-33b6dd125190
# ╟─5ee86537-0bdf-4d20-8617-06a9ae39c929
# ╠═7d514a09-e728-46c1-a3d4-12af8af48ac1
# ╟─936b95f0-c2ea-4612-82d0-7af3ff7b8d1d
# ╟─09334647-ff58-441b-bc5e-aaf8f58955fa
# ╠═69694541-950b-4d24-b85a-a82a13673cf2
# ╟─db687961-99db-4b47-9520-98092fc25693
# ╟─4b27f5b5-b4db-478a-864f-afafc693c850
# ╟─f7fe1256-6f13-4d77-8667-c13751226b36
# ╟─a0062836-3018-439d-b05a-2376f121b2ed
# ╠═bcaffeeb-c8b4-41b3-af0f-134c0e78f9b9
# ╟─dbcc00c1-b6e6-42e6-b782-aa715da4fb45
# ╠═698606b3-45e5-432d-8555-64d7f1a1ad9c
# ╟─b3aa1e53-dc35-410c-92d4-992897bd0d86
# ╟─aade6a3a-1a80-4320-baaf-e83199a5873b
# ╟─782afb46-8292-4041-b6bf-f445ec222c67
# ╟─d057f931-fd1f-447b-8bbe-fc91875250f6
# ╟─f96c348f-352f-4c0b-9597-fb959a5e5131
# ╟─967542e7-a8cf-45b0-bfc6-23af73b756bb
# ╟─bfc0e281-4d55-4840-a56b-b4c36832d7fa
# ╠═be9818f4-178a-4157-a12c-08502b1b8180
# ╟─8cb842fb-7e22-4fda-8414-79419d6027a5
# ╠═2a95f4b6-b91f-46e8-a780-21039bf6a698
# ╟─2f3340ee-e493-46aa-a044-095832bc297c
# ╠═5ff7f35f-5c0e-4f8f-b34d-1b56fa0b4345
# ╟─bfa544d5-cae5-4195-8e78-20479d8bbbb5
# ╠═8c044304-e067-46fd-ae04-2bccf6ceafd6
# ╟─247477d9-6a3d-44f3-b9a0-854cb9abad3b
# ╠═e356bb7b-ae58-4acc-b343-9c010cb014d2
# ╠═30fdadea-198f-4327-ba48-d370210d462e
# ╟─f3743920-b394-45ef-907a-48a1c3f57018
# ╠═5e8b1b7c-29f4-4e10-891c-9ed09e58b04b
# ╟─09abccd2-6c8c-4aaa-ba00-2672ffb0e960
# ╠═b88936da-4c40-4b45-a7c1-bd74d72b8478
# ╠═76a24a28-4ae1-42c9-bb61-b0edcd0c7565
# ╟─fcfd8238-9bbc-45c1-9955-d5ad0adaac40
# ╠═b65e4278-1fe1-458e-8c9b-d79caf9b83eb
# ╠═a4d4e1d3-0f7b-4fbc-a173-ea9e1ee121bb
# ╠═30c676d2-fbe2-402e-b443-a2b547ada139
# ╠═83886f8d-8dad-4d70-b3d6-236ab1e3835e
# ╠═390f7bb4-55d8-44ba-b229-7d66ac4fbe4e
# ╠═f8d3a67e-d3c5-49e7-9b93-4b31961e2e14
# ╟─284ad6b5-0a55-45ac-b4d6-864734f818c7
# ╟─7b4a8c04-91c8-46e7-b78b-117abe1f269a
# ╟─8b75a89f-d2ec-472d-8842-da7975f6e2b3
# ╟─7721656e-74ea-4ae0-a17c-8f13e99217a5
# ╠═18c765e3-0e89-47b5-8684-5b32b9c4f4b7
# ╟─392abdee-54ed-4c50-913e-b17d518c10fe
# ╠═dec1445f-e27f-4631-8bba-3d79a84ae902
# ╟─8dbdf7ae-6a75-46d6-88e7-16e57339bb18
# ╠═debf8d0e-7ebe-4bb0-991b-f1da7973e361
# ╟─ea10b479-5468-4390-aad7-00b8c209fb5e
# ╠═7b964da0-a9c2-4a56-bb7a-655873ae1b98
# ╟─c99a124b-ea0b-4cc5-b4ec-ec41e7f9a76c
# ╠═5bbb5d67-ac9f-447c-b6e9-ac3c8aae5e8d
# ╠═8b9d4401-1566-4475-8082-0ac06f0b98cb
# ╟─0de40dfb-5adb-421c-a3b5-95de4c0d6aee
# ╠═fdab4ca9-5434-4f1a-a3ae-0519aeec4e8e
# ╟─404b660e-9668-448b-bf6d-582cac5f9811
# ╠═ca7a34a8-7313-421f-9234-b78a78cb314c
# ╟─89edb5e9-16e3-4e64-b616-573fa5983c7e
# ╠═f75158da-f80f-4c09-9a3b-ff1716ba033c
# ╠═3dd2b53f-1784-47af-b710-4c31991682c2
# ╟─16d61597-aeea-40a9-98fa-4d3f42228996
# ╠═f193e26b-4622-4b7d-a72d-9cd4f5fb94d5
# ╠═05d86af7-d4e6-4a56-90b0-85dd04c15091
# ╟─3007f345-7095-45b8-8dec-e649fefd7936
# ╟─ea7a9d5c-873d-437e-b7a9-a1f4ce45e0f2
# ╟─7f64d35c-6bfe-41f2-9c79-b2fe3c134885
# ╠═69fc9ec5-5b2d-4f1e-8799-b483669e5c07
# ╠═a05e1274-17e8-4def-88cb-2806bc0f50e4
# ╠═31e84d61-61b5-446a-b263-b01d4612a1aa
# ╠═8e9716b9-44cf-496e-b9ec-d3e978cb064a
# ╠═6936c303-df51-496c-ab5d-c56c9f0c29e6
# ╠═b1dc91ee-979d-4c70-89e8-6cc413177377
