### A Pluto.jl notebook ###
# v0.19.12

#> [frontmatter]
#> title = "Accessing Astronomical Data using a custom Python package or Transit Photometry with Lightkurve"
#> date = "2022-10-12"
#> tags = ["astro497", " lightkurve", "python"]
#> description = "Astro 497, Lab 7, Ex 3"

using Markdown
using InteractiveUtils

# ╔═╡ 7848a13b-ce6a-4b3d-9616-cd1822115f40
using BoxLeastSquares

# ╔═╡ f5533f04-4030-11ed-201a-5f6ba991365a
begin
	using PyCall
	using DataFrames
	using Statistics
	using SavitzkyGolay
	using Plots
	using PlutoUI, PlutoTeachingTools 
	# import PyPlot   # For option to use interactive plots (not on Roar)
	# Uncomment next line for every PyPlot figure to appear in an external window
	# PyPlot.ion()
end

# ╔═╡ 3aa6c6e4-da0c-4a5c-932b-0ae069ef2fe1
md"""
# Accessing Data using a custom Python package $br (Transit photometry via Lightkurve)
**Astro 497, Lab 8, Ex3**
"""

# ╔═╡ 9f03ddd9-4c42-43ec-ac58-4ec36f8f354d
TableOfContents()

# ╔═╡ e942b69e-759d-463b-b644-7f0dffbc7ab1
md"""
## Import a Python package 
#### that has already been installed via pip
"""

# ╔═╡ fb5f427c-2527-48dc-8d2f-be1339b7cdcb
md"""
The instructions for importing the lightkurve python package in python say
```python 
import lightkurve as lk
```
Using Julia's [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) package, can import the python lightkurve package using
"""

# ╔═╡ 47401f4e-81f6-47cc-ae6d-e585b882aec3
lk = pyimport("lightkurve")

# ╔═╡ 123ad109-74a1-4657-a2c7-4fe8ca67fcaa
warning_box(md"""
Note that Justin and I already installed the python packages lightcurve, astropy and astroquery on Roar, so you don't need to install those.  If you were to run these on another system (or even on Roar without running the script that's automatically run when you start your JupyterLab session), then you'd need to install those so that they python interpreter that Julia is using knows how to find them.  

Python package management is notoriously messy, so it's not practical for us to diagnose issues with everyone's local instalations.  
That said, I can share what worked for me.
I was able to install lightkurve easily on my home machine by installing PyCall, then running
```shell
~/.julia/conda/3/bin/pip install lightkurve
```
and then restarting Julia.
""")

# ╔═╡ b389bcd3-1d04-4f80-874a-10d2cd3bf672
md"""
## Find avaliable data files
"""

# ╔═╡ 4f683e6e-ee6d-4e3b-a5c3-73d94632992c
md"""
The lightkurve module provides several functions, such as `search_lightcurve()` and `download()`.  We use those directly.
"""

# ╔═╡ 4b5c9437-ab73-49c4-b5a9-cb802a674134
begin 
	target = "Kepler-10"  
	author = "Kepler"
end;

# ╔═╡ 7fb63811-a713-477d-8e0c-1a527a131ff9
search_result = lk.search_lightcurve(target, author=author)

# ╔═╡ f85625bb-d500-44a9-a521-432d9b7c43f6
md"""
### Interlude on variable types
"""

# ╔═╡ f2fc5633-015d-48c1-9837-96f9e109bbd4
md"""
PyCall and Pluto are working together to display the result in a useful way.  For functions that return a simple type, it may be automatically converted to a Julia type.  But for more complex types, PyCall typically leaves the data stored as a  `PyObject` (which can stored any variable returned by python).  If you ever run into trouble when calling other languages from Julia, it's always good to check the types of variables.
"""

# ╔═╡ cf001aa3-fc58-4ec7-a56c-82bf7628b539
typeof(search_result)

# ╔═╡ 6f61fed6-ff0b-4e5e-b889-aa3b3ebd14c6
md"""
Fortunately, we can still access to the data stored in `search_result` easily.  E.g., 
"""

# ╔═╡ 5e9210e9-a036-49ae-a3b8-e3c00d76929c
exposure_times = search_result.exptime

# ╔═╡ 17ea87d2-345d-4a10-b8a2-4ada7d9626f8
exposure_times[1]

# ╔═╡ 1fdeafb4-4968-4fc0-bfcd-b7256db9957f
md"""
Now, let's check the type of exposure_times.
"""

# ╔═╡ f3e8822e-cf7f-4199-9ac7-cad2ee91b8d3
typeof(exposure_times)

# ╔═╡ b0a54167-99ff-4b1d-804f-0439d523f78a
md"""
Since a vector of `Float64`'s is a very common data type, PyCall knows how to access that data as a native Julia vector.
"""

# ╔═╡ 95a30412-833b-4157-8f03-3e880e3593f7
md"""
It turns out that strings are more complicated than they first seem.  (E.g., does a string use ASCII, unicode, which encoding). So it's often necessary to manually convert Python strings to your desired Julia string type.  E.g., 
"""

# ╔═╡ c6cfbc9d-3217-48d3-b67a-e0538a5845ae
typeof(search_result.mission)

# ╔═╡ 679feb5b-a6cb-491e-ac9c-f98572de3154
search_result.mission[1]

# ╔═╡ 314b09d2-c255-4a62-9cf1-162db53a4023
convert(String,search_result.mission[1])

# ╔═╡ 21b82c12-6545-4e45-9ce7-b5d0a3444805
mission_strs = convert.(String,search_result.mission)

# ╔═╡ 9b791bdb-3da5-4af6-8e13-798f9bf052e7
md"""
Now that we have access to the data as a native julia type, we can use all the usual Julia functions to manipulate it efficiently.  E.g., 
"""

# ╔═╡ 88937dab-0b30-4a94-a51e-3e6d1e3a2c14
sort(unique(mission_strs))

# ╔═╡ 89f988d4-2df7-4e1c-b634-157032b1e66b
md"""
Note that (perhaps suprisingly) the MAST archive is distinguishing between data collected in different "quarters" by including that information in the "mission" field.
"""

# ╔═╡ 5615f327-d49b-4297-9a0a-5bad16a1c692
md"""
## Selecting which file to download
"""

# ╔═╡ 805e7537-c1c1-4ebd-b6fd-951bf4c539b0
md"""
We could download all those files using `search_result.download()` but that might be more data than we actually need.  Let's choose just one file to download.
"""

# ╔═╡ 2c3177d3-a1da-4395-bdaa-dbe9c603f615
md"""
Often it's useful to get a vector of all the unique values in a column.  E.g., 
"""

# ╔═╡ 89ac2dbd-4da7-4213-81d2-fbe8a227bc3c
unique(search_result.author)

# ╔═╡ a3929664-ef64-4864-81ea-bce46846e79d
md"""
Since we specified a single "author" in our search command, we can expect that all the rows returned will have that same author.
"""

# ╔═╡ b7186166-d0b0-44b3-8521-0a2624b860b1
md"""
In contrast, we didn't, specify an exposure time in our search, so our list of available files might include both "short cadnence" (or "SC") observations (60s integration times)  and "long cadence" (or "LC") observations (1800s integration times).  (Note that short cadence observations are not avaliable for all targets or even all months for a given target.)
"""

# ╔═╡ 4137f164-d107-4e55-ae66-dfaf660bf6fb
unique(exposure_times)

# ╔═╡ 14910992-bc21-4f3a-abb4-cef9bcfb6b4f
md"""
Now, we could try searching for $(author) lightcurves of $(target) with a single exposure time and quarter, using optional arguments for lightkurve's `search_lightcurve` function.
"""

# ╔═╡ 07f46e88-b411-468a-b549-0fa9141e3515
search_result_q2_sc = lk.search_lightcurve(target, author=author, quarter=2, exptime=1800)

# ╔═╡ fc6c5840-11d5-4f3a-a5ba-92a9f6e4c9ec
md"""
### Download a lightcurve
Now that we've identified a single file, let's download it using lightkurve's `download` function (technically it's a method provided by the `search_result_q2_sc` object). 
"""

# ╔═╡ 14803855-13e3-4014-bde3-2a201406b489
lc = search_result_q2_sc.download()

# ╔═╡ ed0a8213-652b-4fff-94ea-2fb520608f88
md"""
## Working with data directly
"""

# ╔═╡ 3d55e43d-a7c1-4fd6-9609-b9aad7c30a4a
md"""
As before, `lc` and the individual columns are stored as native python objects (so they can be used with other python functions).  If we instead want access to the values, we can access those directly using `.value`.  E.g., 
"""

# ╔═╡ beae1fdc-2e62-4508-a4af-39f7a64f4b84
lc.flux.value

# ╔═╡ 4532fb44-da7a-4472-a020-1b5870a929a0
md"""
At this point, we could take over doing most everything else with Julia code.
For example, we could plot the light curve.
"""

# ╔═╡ f45509e8-790d-4e5b-b4bd-91a5139733a8
scatter(lc.time.value,lc.flux.value , markersize=0,label=:none)

# ╔═╡ c862e97c-b506-4a0b-be6e-de06a0b08636
md"""
A very small fraction of outlier points are causing the default scale to be inconveneient.  So we could skip plotting points with flux values set to NaN or having data quality issues.
"""

# ╔═╡ be5e0206-45f9-4b96-ac54-63f5852a186a
mask = (.!isnan.(lc.flux.value)) .&& (lc.quality .== 0)

# ╔═╡ 7a430ffc-f630-4ae5-abf9-31f9ce6c688e
begin 
	t_clean = lc.time.value[mask]
	flux_clean = lc.flux.value[mask]
	flux_err_clean = lc.flux_err.value[mask]
end;

# ╔═╡ ef37a958-27eb-4573-a532-7ff7bc296e84
ylims_raw = quantile(flux_clean,[0,0.999])

# ╔═╡ 8515dfc4-1338-4bea-8cbb-9176922e2918
scatter(t_clean,flux_clean, ylims=ylims_raw, markersize=0.5,label=:none)

# ╔═╡ 3a7df884-de1b-49e5-95a0-1e0302c5f969
md"""
There's clearly some low-frequency (i.e., long-term) trends, potentially due to instrumental or stellar variability.  We calculate a smoothed version of the light curve ("low-pass filtered") and divide the light curve by that to get a "flattened" light curve.
"""

# ╔═╡ 2ef09549-b3aa-430a-9615-b64e0c9cc313
begin
	sv_width = 101 # number of points to use
	sv_order = 2   # order of polynomial to use 
	lc_smoothed = savitzky_golay(flux_clean, sv_width, sv_order)
	lc_flat = flux_clean ./ lc_smoothed.y  # smoothed light curve stored in y
	lc_err_flat = flux_err_clean ./ lc_smoothed.y  # remember to scale errors to match
end;

# ╔═╡ 2c92fd7a-ef5a-4700-8947-13f591875959
let 
	ylims_flat = quantile(lc_flat,[0,0.9995])
	plt = scatter(t_clean,lc_flat, ylims=ylims_flat, markersize=0.5,label=:none)
end

# ╔═╡ 9b1b3205-6c04-4aab-a161-030f08e7740e
md"""
That would be a reasonable starting point to look for transiting planets.
For example, you might use the Box-Least Squares algorithm implemented in [BoxLeastSquares.jl](https://github.com/JuliaAstro/BoxLeastSquares.jl)
"""

# ╔═╡ d70e87ab-0a54-4523-b84e-93486dc1793d
begin
	durations_to_search = [0.05, 0.10, 0.15, 0.20, 0.25, 0.33]
	bls_result = BLS(t_clean, lc_flat, lc_err_flat; duration = durations_to_search )
end

# ╔═╡ 83d196c4-37c9-4f7b-a592-5df453ccb9c9
md"""
Many julia high-level functions return a NamedTuple containing the results, as well as additional information.  You can quickly check what fields are avaliable, using `fieldnames()`.  (Of course, we should always read the documentation to understand what is contained in each field.)
"""

# ╔═╡ 76046252-95be-4a04-8bbd-b35c8a489a0a
fieldnames(typeof(bls_result))

# ╔═╡ aec4fcec-0c8f-4669-83a8-9d5c50c2ee8f
md"""
We can plot the results of the BLS periodogram to see if there are any periods with significantly power, indicative of a periodicity and potentially a transiting planet.
"""

# ╔═╡ cfc91b11-22db-46b7-be68-7327151092fa
plot(bls_result.periods,bls_result.power, xlabel="Period (d)", ylabel="BLS Power", label=:none, title=target, xscale=:log10)

# ╔═╡ 7f10d9af-261e-497a-b332-f14deb501cb2
md"""
The `BoxLeastSquares.params()` function will find the orbital period that has the most BLS power and return the best-fit depth, duration and time offset (`t0`) for that period.
"""

# ╔═╡ ed1a2a78-e3ee-448d-990b-e7a20283c69d
BoxLeastSquares.params(bls_result)

# ╔═╡ 02990e13-392c-4d41-9c17-ba6119d3b7b7
md"""
Now, we can plot the (cleaned and flatted) flux folded at the putative orbital period.
"""

# ╔═╡ 156a7141-8ae3-42e6-88ab-708eaa89693b
begin 
	plt_folded1 = plot(xlabel="Phase", ylabel="Flux", xlims=(-0.2, 0.2), legend=:bottomright)
	
	bls_param = BoxLeastSquares.params(bls_result)
	wrap1 = 0.5 * bls_param.period
	phases1 = @. (mod(t_clean - bls_param.t0 + wrap1, bls_param.period) - wrap1) / bls_param.period
	inds1 = sortperm(phases1)
	
	bls_model = BoxLeastSquares.model(bls_result)
	scatter!(plt_folded1, phases1[inds1], lc_flat[inds1], yerr=lc_err_flat[inds1],
    markersize=1.5, markerstrokewidth=0, label="Flattend Data")
	plot!(plt_folded1, phases1[inds1], bls_model[inds1], lw=3, label="BLS Model")
end

# ╔═╡ 6187e095-fe22-4430-9720-4a261083a5c4
md"""
## Using Lightkurve tools
"""

# ╔═╡ 951b8948-515a-4dd3-b790-dd4265dc3479
md"""
Lightkurve includes some tools for common data maniuplations.  For example, we can divide the light curve by the output of a low-pass filter to remove long-term trends using and do a simple search for transits using a Box-Least-Squares periodogram  to identify the putative orbital period of planet candidates.
"""

# ╔═╡ b41c2f99-4d6f-4523-bc9b-3690697d4186
begin 
	lc_wo_nans = lc.remove_nans()
	lc_wo_outliers = lc_wo_nans.remove_outliers()
	lc_flat2 = lc_wo_outliers.flatten()
 end

# ╔═╡ 8ebe5e09-2191-45ca-9cb3-9b02c4e0870f
tip(md"""
Many packages (whether julia or python) will provide functions that have default parameter values.  
For example, optional parameters that affect how aggressively `remove_outliers` will remove outliers or how aggressively `flatten` will filter the light curve.  
While it's often useful to use the default parameters when first getting your code working, you should **not** assume that the default parameters are appropriate for your science goals.  
Most mature packages will include information about each parameter (whether required or optional).  
At a bare minimum, for any scientific purposes (or your project), you should look up what values are being used by default and think about whether those are reasonable.  
(Once you've done that, it's better to specify them manually.  
That way it's clear to others (or your future self) that those choices were deliberate.  
And it prevents the results from changing unexpectedly if a future version of a package updates the default parameter values.
Even better, it's wise to try some alternative parameter values and see how sensitive the results are to those. 
If results change significantly for reasonable parameter values, then you will want to think about them more carefully.
""")

# ╔═╡ 1c665f5c-fb2e-4b55-8eed-29c685ee3186
warning_box(md"""
Note that lightkurve's `remove_outliers()` method did *not* remove points that were flagged as low data quality (non-zero values).  So we should keep our eyes open for potential differences between our analysis above and the following using lightkurve's built-in functions.
""")

# ╔═╡ 0d6f3bab-b447-4545-8322-2e6c31997be1
md"""
Lightkruve also wraps functionality from scipy to compute a BLS periodogram of the flattened flux and find the period with the most BLS power.
"""

# ╔═╡ 46f90630-a01a-4c81-a578-4d5f02bf8362
begin
	bls_periodogram = lc_flat2.to_periodogram("bls")
	bls_periodogram.period_at_max_power
end

# ╔═╡ 49868fe9-b22f-4c3e-9f1a-512e2cc096d8
md"""
In this case, the type of `period_at_max_period` is an array, so to get the results as a scalar, we'd use [1] or `first()`.
"""

# ╔═╡ a3fc7a5d-e1fd-42df-b713-6631bb97ca6b
period_guess = first(bls_periodogram.period_at_max_power)

# ╔═╡ 18ce77c4-40c2-4964-87d7-cd495db12bdf
md"""
We can make a similar blox of the light curve folded at the putative orbital period.
"""

# ╔═╡ f3a2d7b6-02c3-4b4e-a95d-c74653d52883
begin
	wrap2 = 0.5 * period_guess
	lk_t0 = 0.0
	phases2 = @. (mod(t_clean - lk_t0 + wrap2, period_guess) - wrap2) / period_guess
	inds2 = sortperm(phases2)
	
	plt_folded2 = plot(xlabel="Phase", ylabel="Flux", xlims=(-0.2, 0.2), legend=:bottomright)
	scatter!(plt_folded2, phases2[inds2], lc_flat[inds2], yerr=lc_err_flat[inds2],
    markersize=1.5, markerstrokewidth=0, label="Flattend Data")
	
end

# ╔═╡ 097ea7ea-3ed6-495a-9f0b-bf0f1962d8d6
md"""
## Comparing results
"""

# ╔═╡ 11ab7e87-4844-4ca6-a55d-9a98daccec90
md"""
Since most of our analysis with Julia's packages and lightkurve's packages were similar, the two best-fit periods should be very close to each other, but there is likely a small difference.  Let's check.
"""

# ╔═╡ 0b245bca-b382-4e4f-9920-afbea209e836
 bls_param.period-period_guess

# ╔═╡ 7eaafc4e-b1ba-4500-9f97-2b1213eb2bfa
md"""
**Q1a:** List at least four possible reasons for the difference in the putative orbital periods from the two analyses.
"""

# ╔═╡ d08df8bd-b2fd-43d9-a4f7-33198d3dc7a0
response_1a = missing
#=
md"""
1. Issue 1
2. Issue 2
3. Issue 3
4. Issue 4
"""
=#

# ╔═╡ a5a582eb-b3ea-41a4-b48e-7c2d40e315d2
if ismissing(response_1a)  still_missing()  end

# ╔═╡ 98eaca66-21ff-4c4b-a3e4-fd3f0c273c39
md"""
Let's compare the two side-by-side.  (It may be helpful to select full width mode below and maximize the size of your browser window.)
"""

# ╔═╡ 19746dcf-09cc-4d68-a1f2-fc6b4d311b5d
ChooseDisplayMode()

# ╔═╡ 18cec6ef-62c9-4fac-b401-e477ffc9748d
TwoColumn(title!(plt_folded1,"Results from Julia analysis"),title!(plt_folded2,"Results from lightkurve analysis"))

# ╔═╡ f5f73578-bad3-4a49-97c1-f959a4001206
md"""
I didn't plot the BLS model from lightkurve, since I couldn't find how to get the epcoh or depth of transit.  So you can ignore the shift in phase and lack of a red line.
"""

# ╔═╡ a5156de5-2047-47ff-b934-dbb669f45cba
md"""
**Q2a:** Find at leats two other differences in the above plots.  
"""

# ╔═╡ 4e33a464-c58a-4b1e-8061-e9d2a343b798
response_2a = missing
#=
md"""
1. Issue 1
2. Issue 2
"""
=#

# ╔═╡ 5f65dc6c-8652-42cb-b9ce-b3e6079d51b5
if ismissing(response_2a)  still_missing()  end

# ╔═╡ b167dbe9-fcce-4256-8c59-c97c6a016c17
md"""
**Q2b:** What could explain the differences you identified in 2a?
"""

# ╔═╡ 03a7647d-bb57-43d6-8a00-1a6abea1b461
response_2b = missing
#=
md"""
1. Issue 1
2. Issue 2
"""
=#

# ╔═╡ 3212122e-9d06-4569-9cac-6e035eb1ff93
if ismissing(response_2b)  still_missing()  end

# ╔═╡ c741434e-6aac-4486-8753-35cd66e7fd85
md"""
## Plotting from python packages (very optional)
"""

# ╔═╡ f6442a04-2182-439e-a599-e25527c66418
md"""
Lightkurve provides a `plot()` function to provide a quick and dirty plot for several variables returned by lightkurve.  
The result is a PyObject.  To display the figure inside a Pluto notebook, we just add `.figure`. 
E.g.,
"""

# ╔═╡ e51f3021-08b1-4fa8-bd67-d7ea4d9ce8a5
lc_flat2.plot().figure

# ╔═╡ 65f74bbb-d476-409b-a2b7-babc1fcf2a9d
bls_periodogram.plot().figure

# ╔═╡ f327648a-bf94-4d65-9444-ffc94684e080
md"""
Functions like these can be very helpful for quick checks to make sure that things are proceeding the way you expect.  
But usually, you'll want to make some customizations and want to remake the figures manually before using them for a publication.
"""

# ╔═╡ b323de17-0f51-4bb1-9f42-107420722e28
md"""
# Setup
"""

# ╔═╡ a00b0328-6257-4969-aac4-c1428a4875b1
#= 
md"""
For interactive figures, you'll need to load the julia package, PyPlot.jl, and turn on interactive plotting with `PyPlot.ion()`.  
If you want all your plots to appear in separate windows, then you can set that in the package cell, right after loading PyPlot.  
If you want to mix embedded figures and interactive figures, then it's best to wrap the cell with calls to `ion()` and `ioff()`.
"""
=#

# ╔═╡ 960735e4-2042-4f1c-be01-11a9bad545b8
#=
begin 
	PyPlot.ion() 
	plt = bls_periodogram.plot()
	PyPlot.ioff() 
end
=#

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BoxLeastSquares = "6c353534-c22b-44cc-9076-7b904de9fadc"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
SavitzkyGolay = "c4bf5708-b6a6-4fbe-bcd0-6850ed671584"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "d332d435b8c0d53d181c883cac6bdc6df46f5ee1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterface]]
deps = ["ArrayInterfaceCore", "Compat", "IfElse", "LinearAlgebra", "Static"]
git-tree-sha1 = "d6173480145eb632d6571c148d94b9d3d773820e"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "6.0.23"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "5bb0f8292405a516880a3809954cb832ae7a31c5"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.20"

[[deps.ArrayInterfaceOffsetArrays]]
deps = ["ArrayInterface", "OffsetArrays", "Static"]
git-tree-sha1 = "c49f6bad95a30defff7c637731f00934c7289c50"
uuid = "015c0d05-e682-4f19-8f0a-679ce4c54826"
version = "0.1.6"

[[deps.ArrayInterfaceStaticArrays]]
deps = ["Adapt", "ArrayInterface", "ArrayInterfaceStaticArraysCore", "LinearAlgebra", "Static", "StaticArrays"]
git-tree-sha1 = "efb000a9f643f018d5154e56814e338b5746c560"
uuid = "b0d46f97-bff5-4637-a19a-dd75974142cd"
version = "0.1.4"

[[deps.ArrayInterfaceStaticArraysCore]]
deps = ["Adapt", "ArrayInterfaceCore", "LinearAlgebra", "StaticArraysCore"]
git-tree-sha1 = "a1e2cf6ced6505cbad2490532388683f1e88c3ed"
uuid = "dd5226c6-a4d4-4bc7-8575-46859f9c95b9"
version = "0.1.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "84259bb6172806304b9101094a7cc4bc6f56dbc6"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.5"

[[deps.BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "eaee37f76339077f86679787a71990c4e465477f"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.4"

[[deps.BoxLeastSquares]]
deps = ["LoopVectorization", "RecipesBase", "Statistics"]
git-tree-sha1 = "782b60623b5365bddb9dce0fabaf4c5c12ec9b5c"
uuid = "6c353534-c22b-44cc-9076-7b904de9fadc"
version = "0.2.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CPUSummary]]
deps = ["CpuId", "IfElse", "Static"]
git-tree-sha1 = "9bdd5aceea9fa109073ace6b430a24839d79315e"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.1.27"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CloseOpenIntervals]]
deps = ["ArrayInterface", "Static"]
git-tree-sha1 = "5522c338564580adf5d58d91e43a55db0fa5fb39"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.10"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "1833bda4a027f4b2a1c984baddcf755d77266818"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.1.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "6e47d11ea2776bc5627421d59cdcc1296c058071"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.7.0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CpuId]]
deps = ["Markdown"]
git-tree-sha1 = "fcbb72b032692610bfbdb15018ac16a36cf2e406"
uuid = "adafc99b-e345-5852-983c-f28acb93d879"
version = "0.3.1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "db2a9cb664fcea7836da4b414c3278d71dd602d2"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.6"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "992a23afdb109d0d2f8802a30cf5ae4b1fe7ea68"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.11.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "187198a4ed8ccd7b5d99c41b69c679269ea2b2d4"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.32"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "a9ec6a35bc5ddc3aeb8938f800dc599e652d0029"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.69.3"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "bc9f7725571ddb4ab2c4bc74fa397c1c5ad08943"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.69.1+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fb83fbe02fe57f2c068013aa94bcdf6760d3a7a7"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+1"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "4abede886fcba15cd5fd041fef776b230d004cee"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.4.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "b7b88a4716ac33fe31d6556c02fc60017594343c"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.8"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0f960b1404abb0b244c1ece579a0ec78d056a5d1"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.15"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LayoutPointers]]
deps = ["ArrayInterface", "ArrayInterfaceOffsetArrays", "ArrayInterfaceStaticArrays", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static"]
git-tree-sha1 = "b67e749fb35530979839e7b4b606a97105fe4f1c"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.10"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.LoopVectorization]]
deps = ["ArrayInterface", "ArrayInterfaceCore", "ArrayInterfaceOffsetArrays", "ArrayInterfaceStaticArrays", "CPUSummary", "ChainRulesCore", "CloseOpenIntervals", "DocStringExtensions", "ForwardDiff", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "SIMDDualNumbers", "SIMDTypes", "SLEEFPirates", "SnoopPrecompile", "SpecialFunctions", "Static", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "0df040801f5577d6f04bed7af082b1709071af93"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.131"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.ManualMemory]]
git-tree-sha1 = "bcaef4fc7a0cfe2cba636d84cda54b5e4e4ca3cd"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.8"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "6872f9594ff273da6d13c7c1a1545d5a8c7d0c1c"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.6"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "1ea784113a6aa054c5ebd95945fa5e52c2f378e7"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.7"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "02be9f845cb58c2d6029a6d5f67f4e0af3237814"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.1.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "8162b2f8547bc23876edd0c5181b27702ae58dce"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.0.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "f60a3090028cdf16b33a62f97eaedf67a6509824"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.35.0"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "0e8bcc235ec8367a8e9648d48325ff00e4b0a545"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.5"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "d8be3432505c2febcea02f44e5f4396fae017503"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "2777a5c2c91b3145f5aa75b61bb4c2eb38797136"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.43"

[[deps.PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "b42fb2292fbbaed36f25d33a15c8cc0b4f287fcf"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.1.10"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "53b8b07b721b77144a0fbbbc2675222ebf40a02d"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.94.1"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "612a4d76ad98e9722c8ba387614539155a59e30c"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.0"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "017f217e647cf20b0081b9be938b78c3443356a0"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.6"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "dad726963ecea2d8a81e26286f625aee09a91b7c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.4.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMDDualNumbers]]
deps = ["ForwardDiff", "IfElse", "SLEEFPirates", "VectorizationBase"]
git-tree-sha1 = "dd4195d308df24f33fb10dde7c22103ba88887fa"
uuid = "3cdde19b-5bb0-4aaf-8931-af3e248e098b"
version = "0.1.1"

[[deps.SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[deps.SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "938c9ecffb28338a6b8b970bda0f3806a65e7906"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.36"

[[deps.SavitzkyGolay]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "2032cd7dc8664036503bec0c1610d9392bf9047e"
uuid = "c4bf5708-b6a6-4fbe-bcd0-6850ed671584"
version = "0.6.2"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "de4f0a4f049a4c87e4948c04acff37baf1be01a6"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.7.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "2d7164f7b8a066bcfa6224e67736ce0eb54aef5b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.9.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "f8629df51cab659d70d2e5618a430b4d3f37f2c3"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.5.0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static"]
git-tree-sha1 = "3bc5ea8fbf25f233c4c49c0a75f14b276d2f9a69"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.51"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─3aa6c6e4-da0c-4a5c-932b-0ae069ef2fe1
# ╟─9f03ddd9-4c42-43ec-ac58-4ec36f8f354d
# ╟─e942b69e-759d-463b-b644-7f0dffbc7ab1
# ╟─fb5f427c-2527-48dc-8d2f-be1339b7cdcb
# ╠═47401f4e-81f6-47cc-ae6d-e585b882aec3
# ╟─123ad109-74a1-4657-a2c7-4fe8ca67fcaa
# ╟─b389bcd3-1d04-4f80-874a-10d2cd3bf672
# ╟─4f683e6e-ee6d-4e3b-a5c3-73d94632992c
# ╠═4b5c9437-ab73-49c4-b5a9-cb802a674134
# ╠═7fb63811-a713-477d-8e0c-1a527a131ff9
# ╟─f85625bb-d500-44a9-a521-432d9b7c43f6
# ╟─f2fc5633-015d-48c1-9837-96f9e109bbd4
# ╠═cf001aa3-fc58-4ec7-a56c-82bf7628b539
# ╟─6f61fed6-ff0b-4e5e-b889-aa3b3ebd14c6
# ╠═5e9210e9-a036-49ae-a3b8-e3c00d76929c
# ╠═17ea87d2-345d-4a10-b8a2-4ada7d9626f8
# ╟─1fdeafb4-4968-4fc0-bfcd-b7256db9957f
# ╠═f3e8822e-cf7f-4199-9ac7-cad2ee91b8d3
# ╟─b0a54167-99ff-4b1d-804f-0439d523f78a
# ╟─95a30412-833b-4157-8f03-3e880e3593f7
# ╠═c6cfbc9d-3217-48d3-b67a-e0538a5845ae
# ╠═679feb5b-a6cb-491e-ac9c-f98572de3154
# ╠═314b09d2-c255-4a62-9cf1-162db53a4023
# ╠═21b82c12-6545-4e45-9ce7-b5d0a3444805
# ╟─9b791bdb-3da5-4af6-8e13-798f9bf052e7
# ╠═88937dab-0b30-4a94-a51e-3e6d1e3a2c14
# ╟─89f988d4-2df7-4e1c-b634-157032b1e66b
# ╟─5615f327-d49b-4297-9a0a-5bad16a1c692
# ╟─805e7537-c1c1-4ebd-b6fd-951bf4c539b0
# ╟─2c3177d3-a1da-4395-bdaa-dbe9c603f615
# ╠═89ac2dbd-4da7-4213-81d2-fbe8a227bc3c
# ╟─a3929664-ef64-4864-81ea-bce46846e79d
# ╟─b7186166-d0b0-44b3-8521-0a2624b860b1
# ╠═4137f164-d107-4e55-ae66-dfaf660bf6fb
# ╟─14910992-bc21-4f3a-abb4-cef9bcfb6b4f
# ╠═07f46e88-b411-468a-b549-0fa9141e3515
# ╟─fc6c5840-11d5-4f3a-a5ba-92a9f6e4c9ec
# ╠═14803855-13e3-4014-bde3-2a201406b489
# ╟─ed0a8213-652b-4fff-94ea-2fb520608f88
# ╟─3d55e43d-a7c1-4fd6-9609-b9aad7c30a4a
# ╠═beae1fdc-2e62-4508-a4af-39f7a64f4b84
# ╟─4532fb44-da7a-4472-a020-1b5870a929a0
# ╠═f45509e8-790d-4e5b-b4bd-91a5139733a8
# ╟─c862e97c-b506-4a0b-be6e-de06a0b08636
# ╠═be5e0206-45f9-4b96-ac54-63f5852a186a
# ╠═7a430ffc-f630-4ae5-abf9-31f9ce6c688e
# ╠═ef37a958-27eb-4573-a532-7ff7bc296e84
# ╠═8515dfc4-1338-4bea-8cbb-9176922e2918
# ╟─3a7df884-de1b-49e5-95a0-1e0302c5f969
# ╠═2ef09549-b3aa-430a-9615-b64e0c9cc313
# ╠═2c92fd7a-ef5a-4700-8947-13f591875959
# ╟─9b1b3205-6c04-4aab-a161-030f08e7740e
# ╠═7848a13b-ce6a-4b3d-9616-cd1822115f40
# ╠═d70e87ab-0a54-4523-b84e-93486dc1793d
# ╟─83d196c4-37c9-4f7b-a592-5df453ccb9c9
# ╠═76046252-95be-4a04-8bbd-b35c8a489a0a
# ╟─aec4fcec-0c8f-4669-83a8-9d5c50c2ee8f
# ╠═cfc91b11-22db-46b7-be68-7327151092fa
# ╟─7f10d9af-261e-497a-b332-f14deb501cb2
# ╠═ed1a2a78-e3ee-448d-990b-e7a20283c69d
# ╟─02990e13-392c-4d41-9c17-ba6119d3b7b7
# ╠═156a7141-8ae3-42e6-88ab-708eaa89693b
# ╟─6187e095-fe22-4430-9720-4a261083a5c4
# ╟─951b8948-515a-4dd3-b790-dd4265dc3479
# ╠═b41c2f99-4d6f-4523-bc9b-3690697d4186
# ╟─8ebe5e09-2191-45ca-9cb3-9b02c4e0870f
# ╟─1c665f5c-fb2e-4b55-8eed-29c685ee3186
# ╟─0d6f3bab-b447-4545-8322-2e6c31997be1
# ╠═46f90630-a01a-4c81-a578-4d5f02bf8362
# ╟─49868fe9-b22f-4c3e-9f1a-512e2cc096d8
# ╠═a3fc7a5d-e1fd-42df-b713-6631bb97ca6b
# ╟─18ce77c4-40c2-4964-87d7-cd495db12bdf
# ╠═f3a2d7b6-02c3-4b4e-a95d-c74653d52883
# ╟─097ea7ea-3ed6-495a-9f0b-bf0f1962d8d6
# ╟─11ab7e87-4844-4ca6-a55d-9a98daccec90
# ╠═0b245bca-b382-4e4f-9920-afbea209e836
# ╟─7eaafc4e-b1ba-4500-9f97-2b1213eb2bfa
# ╠═d08df8bd-b2fd-43d9-a4f7-33198d3dc7a0
# ╟─a5a582eb-b3ea-41a4-b48e-7c2d40e315d2
# ╟─98eaca66-21ff-4c4b-a3e4-fd3f0c273c39
# ╠═19746dcf-09cc-4d68-a1f2-fc6b4d311b5d
# ╟─18cec6ef-62c9-4fac-b401-e477ffc9748d
# ╟─f5f73578-bad3-4a49-97c1-f959a4001206
# ╟─a5156de5-2047-47ff-b934-dbb669f45cba
# ╠═4e33a464-c58a-4b1e-8061-e9d2a343b798
# ╟─5f65dc6c-8652-42cb-b9ce-b3e6079d51b5
# ╟─b167dbe9-fcce-4256-8c59-c97c6a016c17
# ╠═03a7647d-bb57-43d6-8a00-1a6abea1b461
# ╟─3212122e-9d06-4569-9cac-6e035eb1ff93
# ╟─c741434e-6aac-4486-8753-35cd66e7fd85
# ╠═f6442a04-2182-439e-a599-e25527c66418
# ╠═e51f3021-08b1-4fa8-bd67-d7ea4d9ce8a5
# ╠═65f74bbb-d476-409b-a2b7-babc1fcf2a9d
# ╟─f327648a-bf94-4d65-9444-ffc94684e080
# ╟─b323de17-0f51-4bb1-9f42-107420722e28
# ╠═f5533f04-4030-11ed-201a-5f6ba991365a
# ╟─a00b0328-6257-4969-aac4-c1428a4875b1
# ╟─960735e4-2042-4f1c-be01-11a9bad545b8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
