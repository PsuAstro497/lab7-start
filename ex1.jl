### A Pluto.jl notebook ###
# v0.19.12

#> [frontmatter]
#> title = "Queries & Data Wrangling"
#> date = "2022-10-12"
#> tags = ["astro497", "ExoplanetArchive", "Gaia", "ADQL", "TAP", "Dataframes", "joins"]
#> description = "Astro 497, Lab 7, Ex 1"

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ d68a116b-83e3-43a0-8483-399eacbe9a76
begin 
	using PlutoUI, PlutoTest, PlutoTeachingTools
	using CSV, DataFrames, Query
	using Downloads, HTTP
	using StatsBase: mean, std
	using Plots, ColorSchemes
end

# ╔═╡ df95d06f-29c8-44b6-8def-556ca63bc1eb
md"""
# Queris & Data Wrangling
**Astro 497, Lab 8, Ex 1**
"""

# ╔═╡ 78846201-8190-4ebe-845c-9d8fc92b805a
TableOfContents()

# ╔═╡ 6e9d46e2-752b-4d84-aec8-c39232a2aed3
md"""
In this exercise, you'll get to practice querying databases and performing basic manipulations like selecting columns, filtering rows, joining DataFrames, grouping them, and combining information within groups.  
The short-term goal is for you to become comfortable in using these foundational operations to accomplish basic data wrangling tasks.  In the longer term, you'll likely put these skills to use as part of ingesting, cleaning and transforming data in the [dashboard](https://psuastro497.github.io/Fall2022/project/) you develop for the class project.

There are many online resources that can help you learn how to use these tools, including the [Julia Data Science online textbook](https://juliadatascience.io/dataframes) and the documentation for [DataFrames.jl](https://dataframes.juliadata.org/stable/man/working_with_dataframes/) and [Query.jl](https://github.com/queryverse/Query.jl).
"""

# ╔═╡ 1cce5341-4e39-4110-8b97-f570154400a9
md"""
# Queries with ADQL + TAP 
"""

# ╔═╡ bf780106-afd3-4e26-8673-d5c27953c125
md"""
We can use `make_tap_query_url` to make building queries a little easier to write (and read).  For example, 
"""

# ╔═╡ 3c58158d-183b-4224-af8f-c50289c7bcbe
md"""
### Download a largish table into a file
"""

# ╔═╡ 63c702da-ad9d-4e31-ad26-39e9f12f2061
md"""
Next, we'll load that data into a `DataFrame` using the `CSV.read` function.
(We could explicitly tell it to use tabs as the delimiter between columns by passing the optional arguement `delim='\t'`, but it can also figure that out automatically for us.)
"""

# ╔═╡ 223e5bf8-649a-411b-ad9e-78a4e911d402
md"""
### Download a small table directly into memory
"""

# ╔═╡ bb83b685-8aeb-4dd5-ab61-b6ae0e804d07
md"""
Sometimes, you're making smaller queries and may not want to write them to disk.  In that case, we could instead read them directly into a DataFrame in RAM using the `CSV.read` and `HTTP.get`.  
To simplify things, I've provided a simple function `query_to_df(url)` at the bottom of the notebook.
For example, we can get all the rows and columns of the `keplernames` table (that lists multiple names assigned to Kepler planet candidates) from the Exoplanet Archive using the following commands.
"""

# ╔═╡ 2526fd77-82d2-4a9e-8e41-a5076dc073f0
md"""
# Basic DataFrame Manipulations
"""

# ╔═╡ f9eb814e-923c-44a2-9b50-f1058db26258
md"""
Selecting is so common that there are convient shorthands notations, such as
"""

# ╔═╡ 69718757-73c7-4dc3-a075-478db7d05722
md"""**Q1a:**
Create a new dataframe based on `df_ps_raw` that contains only the following columns: 
- pl_name
- pl_orbper
- pl_rade
- ttv_flag
- sy_pnum
- disc_facility
"""

# ╔═╡ 9105b929-ad4b-48f7-b234-2bab6f3bd524
response_1a =  missing

# ╔═╡ 525c5db3-7e7e-466c-a2b8-1b6d40d5bd64
md"""
## Selecting Rows
"""

# ╔═╡ 4b10f695-5d1c-4072-9d4e-de194db5cdd5
md"""
One very common task is to *filter* a table to find only those rows that mean certain criteria.  
For example, we might want to filter for only planets discovered by a certain survey (using the `disc_facility` column).  
We could do that several ways.  For example,
"""

# ╔═╡ fc77ed7a-d9d3-40dd-adee-502a2226a7c4
protip(md"""
Note that we could have sent a new query adding a `where+disc_facility="HATNet"`. However, since we already have downloaded the planetary systems table to our computer, executing a new query and downloading the results would take much longer.
In many cases, it's most efficient if you can use `select` and `where` to create a query whose that is specific enough that results will be easy to work with on your local computing environment, but general enough that you won't need to redo the query over and over again.  Of course, in some cases, that's not practical and you need to execute many specific queries of the database.
""", invite="Why not query Exoplanet Archive with a `where` statement?")

# ╔═╡ 7b2d6692-5a17-465f-a279-3a7c81d33949
md"""
Next, we'll filter to find those that have a measurement of the Rossiter-McLaughlin effect (reported in column `pl_projobliq`).
"""

# ╔═╡ ea8e29a2-aea5-43da-b72a-a9632dda3078
aside(tip(md"""The `!` operator can be read as "not".  
`==` and `!=` can be read as `equals` and `not equals`.  
The boolean operators `&&` and `||` can be read as "and" and "or", respectively.  
You can use parentheses to specify the order of logical operations.
For more info, see [documentation](https://docs.julialang.org/en/v1/manual/mathematical-operations/#Boolean-Operators)."""),v_offset=-80)

# ╔═╡ d6844a2b-7bf1-4cec-951a-79a5acb205c5
md"""
Sometimes it's useful to build up complex queries incrementally.  
But it's often more efficient to combine tests.  For example, we could do
"""

# ╔═╡ 7d33a883-1d99-4203-a9db-b13b9d659b79
md"""
We can confirm that they give the same results using `isequal`.  
"""

# ╔═╡ 5ddbe9e6-a2aa-4c4f-875c-40cbbc87698d
protip(md"""
If we had tested for equality using `==`, the result would be `missing`, because the tables contain some missing values.  The `==` operator is implemented to return `missing` if the expression on either side is missing.  In contrast, `isequal` returns true if both values are missing.  The only way to know about the behavior of function calls in edge cases like these is to read the documentation.
""")

# ╔═╡ 6b562c9a-121d-4314-818c-751d4f99e186
md"""
**Q1b:**  Apply filter to the `df_raw` dataframe to get all the entries that have a value (other than `missing`) in the `pl_projobliq` column and store the result in the varliable `df_ps_w_rm`.
"""

# ╔═╡ 58aba1d9-5605-4dc7-a613-ffe587a723d0
df_ps_w_rm = missing 

# ╔═╡ fc4a26b6-1325-47ac-9aa8-949343723eff
md"""
**Q1c:** The HAT project eventually expanded to use observatories in both the north and south hemispheres.  Apply filter to the `df_raw` dataframe to get all the entries that have a value (other than `missing`) in the `pl_projobliq` column and were discovered by either "HATNet" or "HATSouth" (as reported in the `disc_facility` column).  Store the result in the variable `df_ps_hatns_w_rm`.
"""

# ╔═╡ 1e81f5ee-5a7e-4777-8f17-b4cc7554b467
df_ps_hatns_w_rm = missing

# ╔═╡ f21b46ad-a293-486b-bafd-24245a3d1511
md"""
## Filter as part of query using `where`
"""

# ╔═╡ 93fff29b-e854-4e7f-99dc-89af1d3b625a
hint(md"In the query to download the data in `df_raw`, we included a `where` statement specifying that we only wanted one entry per planet, the row identified as the default set of parameters.  Often, RM measurements appear in papers that don't remeasure all the basic parameters.  Therefore, many of the RM measurements weren't included in the results of our original query.")

# ╔═╡ 3ecce2ce-adc7-4ea1-b22f-bd9182f5a39a
md"""
We'll build a new query to search the entire planetary systems table and retreive any rows that contain a numerical value for `pl_projobliq`.  
The way ADQL and Julia's dataframes handle missing values is slightly different.  
So our query will specify that the value is not a null value (rather than using `ismissing`).

This time, we'll specify we'd like to be returned by the query.  
To make it easy to construct long strings, I've provided a function `select_cols_for_tap` that turns a vector of strings or symbols into a single string with each column names separated by a `,` so it can be easily dropped into a tap query.
"""

# ╔═╡ 636530dc-146b-4900-a79b-ca66cb4c1e12
md"""
Now we can plot all the RM measurements in the Exoplanet Archive.
"""

# ╔═╡ 0365f044-2533-4580-926c-07e5ebd93ea7
md"""
**Q2a:** Query the exoplanet archive to retrieve all the rows that contain a 
numerical value for `pl_projobliq` and were detected by either the original HATNet (in the northern hemispehre) or HATSouth.  Retrieve only the columns contained in `cols_to_keep`.  Store the result in a dataframe named `df_pl_hatns_w_rm`.
"""

# ╔═╡ 183cffd3-db02-4ba9-86bf-5af28d84cd3b
begin  # replace with your code
	df_pl_hatns_w_rm = missing 
end

# ╔═╡ 4e065419-b812-42af-a48e-830ac222be87
md"""
## Joining tables
"""

# ╔═╡ 533517f8-7db7-44a4-ae1c-a435ba4df597
md"""
Often, we can learn more about a system when we have multiple types of observations.  For example, you might wonder if any of the planets discovered by the HATNet project were also observed by Kepler.  To answer this question, we can check to see if the planet is included in the Kepler Names table at the Exoplanet Archive.
"""

# ╔═╡ c88ebf43-3a11-4416-b36b-e489a8b16f84
md"""
At first, one might think of searching for each planet found by HATNet.  
For large tables, this is extremely inefficient.  
It's much better to perform a *join* to find all the matches in one pass.  
For this question, we want to find all cases where there's a row in `df_ps` (the planetary systems table filtered to include only the one default row per planet, and after selecting just the columns we want to work with) and a row in `df_kepler_names` that have the same value of `pl_name`.  
We can do this with an *inner join*.
"""

# ╔═╡ 8dd3e6d6-c4c4-498b-a917-c1da1938fb07
md"""
The result is a new DataFrame that we can work with as usual to see what names and Kepler ID numbers are used to refer to those same planets.
"""

# ╔═╡ 7b937404-c3c1-4d58-9a07-3c150d14fcc0
md"""
For some purposes, you may want to keep rows where there's not a match (and mark that some columns are missing).  There are several variations, including *left join*, *right join* or *outer join*.  Each is demonstrated below.
"""

# ╔═╡ 32db9a7b-ffbf-44d1-a4b5-fa3ecc2d4098
md"""
**Q3a:** Inspect the table above that compares the number of rows and columns output by each type of join.  In your own words, describe the difference between the left join, right join and outer join operations.
"""

# ╔═╡ db83d146-6954-4b40-9a43-668a5a23aa91
response_3a = missing

# ╔═╡ e1e7c565-aea3-46ce-aa31-c4268a27f5f6
if ismissing(response_3a)
	still_missing()
end

# ╔═╡ b2296ab5-c687-47a3-b5a1-0f458d1407ed
md"""
**Q3b:** Use a filter and a join to find the Kepler id number for any planets discovered by the TrES survey (`disc_facility` equals "TrES").  Store the resulting vector of integers in the variable `response_3b`.
"""

# ╔═╡ 773bd2c2-8276-462c-ac4f-219624101743
begin
	response_3b = missing
end

# ╔═╡ 19fc6a33-c0aa-4a14-b666-365e943e5c30
md"""
# Cross-matching across different surveys/databases
"""

# ╔═╡ 2c18f37c-91da-40d6-aadc-248e86ca7641
md"""
One common task for astronomers is to combine information from different catalogs.  
It can be suprisingly difficult to find the same object in multiple catalogs.  
Here, we'll demonstrate how to match one object from the Exoplanet archive with catalogs from the ESA's Gaia mission.
"""

# ╔═╡ 6dc8da29-aee5-404b-a746-5fca244f5956
protip(md"""ESA also provides a great [web interface](https://gea.esac.esa.int/archive/).  It's particularly useful for prototyping queries (from that webpage, select "Search" and then the "Advanced (ADQL)" tab.)""", invite="Want to try Gaia archive's web interface?")


# ╔═╡ f2dbf301-a4ee-46b4-b927-a490e22ff4f1
md"""
Fortunately, the ESA archive also supports ADQL and TAP and associated [documentation](https://www.cosmos.esa.int/web/gaia-users/archive/programmatic-access#CommandLine_Tap) and [examples](https://www.cosmos.esa.int/web/gaia-users/archive/writing-queries).
Based on that, the base url to use for TAP queries is given below.
"""

# ╔═╡ faab8c3e-b557-4db0-99a3-730e2ec582e2
gaia_query_base_url = 
	"https://gea.esac.esa.int/tap-server/tap/sync?REQUEST=doQuery&LANG=ADQL&FORMAT=csv&QUERY="

# ╔═╡ a8e723f4-1f20-478e-9617-e022f239fece
md"""
## Matching based on shared identifier
"""

# ╔═╡ 90190fe3-4fff-4be9-b494-b249b1f97092
md"""
Fortunately, the Exoplanet Archive includes a column with a Gaia id for most host stars.
"""

# ╔═╡ e9b0320a-aa7f-4afe-9018-25d4ca45ac55
md"""
Since TAP wants to replace spaces with `+`'s, I've created `replace_spaces_for_tap` to provide TAP-friendly string.
"""

# ╔═╡ 07845a5c-5a2c-48a4-96fe-a176d709ea5a
md"""
Now we can build a TAP query very similarly to how we queried the Exoplanet archive.  Since the Gaia ID is for data release (DR) 2, we'll specify the table `gaiadr2.gaia_source`.  
And we'll using a `where` clause to pick only this entry.
"""

# ╔═╡ b865f025-f0cd-4713-a1da-2a57ac3cb997
md"""
When you're ready to run queries against the ESA archive, check this box: $(@bind do_gaia_queries CheckBox())
"""

# ╔═╡ f7d8fc30-b6fa-4122-81c9-a0868fdfefde
md"""
There's been a 3rd Gaia data release, which is avaliable as a separate table `gaiadr3.gaia_source`.  
However, the designation we have is only good for DR2.  
In order to find the corresponding entry in DR3, we can use the `source_id` that we retrieved from Gaia DR2.
"""

# ╔═╡ 6ad9be57-c8e7-4590-9b96-7c3a043c20ad
md"""
### Matching based on position
What if someone else hadn't figured out which Gaia source_id matched a given Kepler target for us?
We could find a matching object in the Gaia catalog based on the right ascension and declination.
"""

# ╔═╡ c75786ee-55b8-4ff6-bb99-d9faa738a01f
md"""
**Q4:** Which row number is the best match to HAT-P-7?
"""

# ╔═╡ a0c53b5e-76ce-428e-bbef-14e09f10ba51
response_4 = missing

# ╔═╡ 5ba92ea8-a92f-4c7e-9a3a-cc7b3fd11585
if ismissing(response_4) still_missing() 
elseif !(typeof(response_4) <: Integer)
	wrong_type(:response_4, Integer)
elseif response_4 != 1
	keep_working()
else
	correct()
end
	

# ╔═╡ 694b1c23-be91-42fa-a20a-69305c117557
md"""
# Grouping DataFrames
"""

# ╔═╡ 8a5200d0-65f6-4be0-b923-c4dbcc3b6330
md"""
Often we want to group data based on the value of one column.  For example, we might want to consider all the RM measurements obtained for planets discovered by a given observatory.  
"""

# ╔═╡ 83a7592d-505d-434d-9810-07bf07cac5fa
md"""
The result is stored as a *GroupedDataFrame*.  Rather than copying of all the data into a set of new data frames, the `DataFrames.jl` package is storing which rows below to which groups and providing a convenient interface to access them by group.
For example, we can check how many groups there are, get a list of keys for each group, and look at how many rows are in each group.
"""

# ╔═╡ a172c8ec-6895-491f-95c2-54fbd524da0a
protip(md"""You could perform a `groupby` operation that uses multiple keys.  
In order to accomoate that, each key acts like a `NamedTuple`.""",
invite="Why did we need to specify `disc_facility` after the key?")

# ╔═╡ a4c12bae-15d9-45bd-80a0-b62225a1487e
md"""
We can then access the contents of any group, as if it were it's own DataFrame.
For example, let's check out group 2, corresponding to planets discovered by multiple observatories.
"""

# ╔═╡ 824b2f54-0cab-4685-bc06-8d3bef3d18f5
md"""
This might be useful for making a more useful visualization of our data.  
For example, we could color code points by which facility discovered the planet.
"""

# ╔═╡ 280ae58d-882b-44aa-a24d-dd3dea1eaacb
md"""
## Split-Apply-Combine Pattern
"""

# ╔═╡ 6bea5705-8898-4ecb-9382-392f9ce79660
md"""
The `combine` function is much more powerful than first meets the eye.
Many calculations can be phrased in the *Split-Apply-Combine* programming pattern.  
Here, `groupby` perform the split step, and `combine` performs both the apply step (i.e., applying a function to each GroupedDataFrame separately) and the combine step (i.e., combining the results into a DataFrame).  
In our examples, the combine step seems trivial.  
But things can get more interesting for large datasets, where the computations are performed in parallel or even distributed over many different computers.  

For example, we can compute the number of rows in each group and the mean of some columns within each group.
"""

# ╔═╡ 95cd722f-0b05-44ec-9a3f-12afa0ee9d2a
md"""
Note that some of the results were missing.  We define custom functions to be used in a transformation (e.g., computing the mean of non-missing values).
"""

# ╔═╡ 67ad9808-ccf9-4b9d-87c0-95ba18c26eef
mean_skipmissing(x) = mean(skipmissing(x))

# ╔═╡ 56aeecf1-34d3-4dfa-a226-cc15b1d82072
md"""
### Transform-Split-Apply-Combine Pattern
Things get even more interesting if we add `transform` to the mix.  
That refers to altering contents of a column or adding a new column (with results computed from data in existing columns).
"""

# ╔═╡ bf75cf8b-77b3-46a4-a8cb-95d551d51241
md"""
For example, the database contains separate columns for the upper and lower measurement uncertainties for `pl_projobl`.  We could add a new column that is the average of their absolute values.  
Or, we could perform steps to lean our data, such as replacing the disc_facility name "Multiple Facilities" with "Multiple Observatories", so those targest will be placed in the same group.
"""

# ╔═╡ 54a1df20-0d15-4a08-86db-6df23e0f7246
md"""
Another common pattern is to create a new column that will be used for the grouping.  
For example, we can add a new column, `is_giant` that indicates if the value in pl_rade is greater than or equal to 6 Earth radii.
Then, we can generate a GroupedDataFrame according to whether the planets are considered a giant planet.  
Finally, we can compute the mean stellar temperature, planet radii and projected obliquity measurements (omitting any missing values) for the groups labeled giants and not giants separately.
This can be done in just three lines of code:  one performing the transform operation, one calling `groupby` and one calling `combine`.
"""

# ╔═╡ 5179edd7-84e8-4161-942b-8036c6984b8b
md"""
**Q5:**  Make a plot of the mean absolute value of the projected obliquity for planets grouped by the effective temperature of their host star.  
We can break this down into the following steps.
1. Start with the dataframe `df_ps_w_rm` (or you can use `df_ps_w_rm_ref` if you have concerns that your implementation above may not be correct).
2.  Copy a new dataframe that removes rows for which `st_teff` is missing.
3.  Add a new column, `st_teff_bin` that contains the stellar effective temperature rounded to the nearest multiple of 600.  (You're welcome to use the function `round_to_nearest_600` defined below.)
4.  Create a GroupedDataFrame based on the value of `st_teff_bin`.
5.  For each group, compute the number of planets in the group (stored as `nrow`), mean effective temperature for stars in that group (to be stored in `st_teff_mean`), the mean and standard deviations of the radii of planets in that group (to be stored in `pl_rade_mean` and `pl_rade_std`), and the mean and standard deviations of the absolute values of the projected obliquities (to be stored in `pl_projobliq_mean_abs` and `pl_projobliq_std_abs`).
6.  Store the resulting DataFrame in the variable `df_pl_w_rm_by_teff`.
7.  Sort the rows of `df_pl_w_rm_by_teff` by `st_teff_bin`.
"""

# ╔═╡ 4c67c356-e198-42d1-8a34-991cd82eed56
round_to_nearest_600(x) = round(Int64,x/600)*600

# ╔═╡ d0e15021-afb0-48b4-9b25-ff0e84074024
begin  # Insert your code for Q4 in this cell
	# Filter
	# Transform
	# Split (or group)
	# Apply
	# Sort
end

# ╔═╡ f02ae91c-4588-4840-a2f2-b6039cf5f222
md"""
Once you code works, then you should see two plots appear below.
"""

# ╔═╡ ab27b832-55dd-4ff7-9692-920a7f0daa4d
if @isdefined df_pl_w_rm_by_teff
	scatter(df_pl_w_rm_by_teff.st_teff_mean, df_pl_w_rm_by_teff.pl_projobliq_mean_abs, yerr = df_pl_w_rm_by_teff.pl_projobliq_std_abs, xlabel="Teff (K)", ylabel="abs(λ)", label=:none)
end

# ╔═╡ 2f4172bd-ebd5-4db2-81f4-c30ba339ffd9
if @isdefined df_pl_w_rm_by_teff
	scatter(df_pl_w_rm_by_teff.st_teff_mean, df_pl_w_rm_by_teff.pl_rade_mean, yerr=df_pl_w_rm_by_teff.pl_rade_std, xlabel="Teff (K)", ylabel="Rₚ (R⊕)", label=:none)
end

# ╔═╡ 8a4ce3c9-a120-41c1-b964-4930d2f04a29
md"""
Notice that there is a gradual trend in the size of planets with RM measurements as a function of host star temperature.  
In contrast, there is a rapid increase in the mean absolute value of λ for stars with effective temperatures larger than ≃ 6200K. 
"""

# ╔═╡ 341035c9-7300-4fa0-90c2-3700f853c865
md"""
# Setup & Helper Code
"""

# ╔═╡ aaa8f0d3-ac73-44b9-a630-eea5671a8f0f
ChooseDisplayMode()

# ╔═╡ 7e39535a-19ab-4b0a-823a-aec792895c68
begin
	datadir = joinpath(pwd(),"data")
	mkpath(datadir)
end

# ╔═╡ be348711-98f9-4654-ac90-3e5fc893a5e2
md"""
## Convenience functions for ADQL & TAP
"""

# ╔═╡ 6bc2a24b-92c5-490d-895e-2c3eabfc3db7
begin
	make_tap_query_url_url = "#" * (PlutoRunner.currently_running_cell_id |> string)
"""
`make_tap_query_url(base_url, table_name; ...)`

Returns url for a Table Access Protocol (TAP) query.
Inputs:
- base url 
- table name
Optional arguments (and default):
- `max_rows` (all)
- `select_cols` (all)
- `where` (no requirements)
- `order_by_cols` (not sorted)
- `format` (tsv)
See [NExScI](https://exoplanetarchive.ipac.caltech.edu/docs/TAP/usingTAP.html#sync) or [Virtual Observatory](https://www.ivoa.net/documents/TAP/) for more info.
"""
function make_tap_query_url(query_base_url::String, query_table::String; max_rows::Integer = 0, select_cols::String = "", where::String = "", order_by_cols::String = "", format::String="tsv" )
	
	query_select = "select"
	if max_rows > 0 
		query_select *= "+top+" * string(max_rows)
	end
	if length(select_cols) >0
		query_select *= "+" * select_cols 
	else
		query_select *= "+*"
	end
	query_from = "+from+" * query_table
	query_where = length(where)>0 ? "+where+" * where : ""
	query_order_by = length(order_by_cols) > 0 ? "+order+by+" * order_by_cols : ""
	query_format = "&format=" * format
	url = query_base_url * query_select * query_from * query_where * query_order_by * query_format
end
end

# ╔═╡ 67be8932-7625-4e83-b42d-9928e36c74c4
Docs.doc(make_tap_query_url)

# ╔═╡ 955eaada-b7c0-41dc-b6a7-e9441ba45404
begin
	nexsci_query_base_url = "https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query="
	planeary_systems_table = "ps"
	url_get_ps_table = make_tap_query_url(nexsci_query_base_url, planeary_systems_table, where="default_flag=1")
end

# ╔═╡ 245c4d7b-d648-4f39-be46-82070c062b86
Markdown.parse("""
For starters, we'll execute a simple query of the [NASA Exoplanet Archive](https://exoplanetarchive.ipac.caltech.edu/) using the Astronomical Data Query Language (ADQL) for writing the queries and teh Table Access Protocol (TAP) for translating them into a url that we can send to the database server.
First, we need to lookup what is the base url to user for queries. 
Step 1 of the [Exoplanet Archive documentation](https://exoplanetarchive.ipac.caltech.edu/docs/TAP/usingTAP.html#sync-async) tells that is 
> $nexsci_query_base_url

Second, we need to decide which table we would like to query and which columns we would like to download.  
Again, we look to the [documentation](https://exoplanetarchive.ipac.caltech.edu/docs/TAP/usingTAP.html) to see that there is a planetary systems table that goes by the name `ps`.  
That table has [lots of columns](https://exoplanetarchive.ipac.caltech.edu/docs/API_PS_columns.html).  
For now, we'll just ask for the available columns by using the `*` wildcard.  
Now, we have a basic, but viable query command
> https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+*+from+ps
If you actually execute that command, it would result receiving a fairly large table (313 MB).  
The main reason it's so big is that it contains a separate row of data for every combination of planet and publication providing some parameters in the database.  
Often there are many papers each reporting measurements of just a few properties of a planet.  
To make using the exoplanet archive more efficient, the planetary systems table includes a column, `default_flag` that is set to 1 for just one row of data for any planet and set to 0 for all the other rows with data about that planet from other sources.  
Rather than downloading the entire table, we'll add a `where` statement to specify that we only want the rows of the table that have the field `default_flag` equal to the value 1, by adding a `where` statement to the url, which becomes 
> $(make_tap_query_url(nexsci_query_base_url, planeary_systems_table, where="default_flag=1"))

By default, the data is returned in the VOTable format.  Julia doesn't (yet) have a native VOTable parser, so we've also specified that we'd like the data in an alternative data format by adding a `format` statement.  
(TSV means tab separated values (for columns; new rows are placed on separate lines).  It's very similar to the CSV (comma separated values) format.  
Ocassionally, entries include commas (e.g., an author list or url to a paper), so using tabs simplifies the parsing of those fields.)

I've provided a simple function [`make_tap_query_url`]($(make_tap_query_url_url)) to make it a little easier to write basic queries.  For complex queries, you may need to write the url out manually, but it should be good enough for all the queries you'll execute in this lab.  Its docstring describes how to call it:
""")

# ╔═╡ d8936c55-4c06-43fc-9d0a-a621d919caab
begin
	filename_ps = joinpath(datadir,"nexsci_ps.tsv")
	if !isfile(filename_ps) || filesize(filename_ps)==0
		Downloads.download(url_get_ps_table, filename_ps)
		fresh_data_ps = true  
	else
		fresh_data_ps = false
	end
	@test filesize(filename_ps) >0	
end

# ╔═╡ 20c76a9c-a759-410b-8ef3-d86bb7640f54
md"""
The above query will result in a file taking $(round(filesize(filename_ps)/ 1024^2,sigdigits=3)) MB of disk space.  
That's not particularly large, but sending the query to the Exoplanet Archive, waiting for their servers to execute the query, and downloading the results over the internet takes long enough that we don't want to be doing that over and over again.   
Therefore, we've saved it into a file on disk, so you only need to do the query and wait for the data to be transferred once.
Then, we'll do most of our manipulations locally.
To submit a url and save the results to a file, we'll use the `download` function from the `Downloads` package.  
We'll need to tell it what file to use for saving the results.  (`datadir` is set near the bottom of the notebook).
We'll also set a variable (`fresh_data_ps`) so that we can tell Pluto if another cell depends on this file. 
That allows Pluto to wait to run those cell until after the file is downloaded (or to rerun them if it's redownloaded).
"""

# ╔═╡ acf3dd12-7187-4967-bc01-954ec8706bc6
begin
	fresh_data_ps # tells Pluto to wait to run this cell until after data download
	df_ps_raw = CSV.read(filename_ps,DataFrame)
end

# ╔═╡ 35440dd6-bb8b-499e-99d9-cb6cc03ccc67
md"""
The full dataframe is consuming $(round(Base.summarysize(df_ps_raw) / 1024^2,sigdigits=3)) MB of RAM on your computer.  In terms of modern day science projects, this isn't large.  In this case, you could get away with not thinking about the memory cost of various operations.  (Indeed, working with a relatively small dataframe is helpful when you're learning and likely to make some mistakes, so you can learn from those more quickly than if you were using a large database.)  In order for that to work, we'll need to pay attention to how much memory our DataFrames are using and how many memory allocations are occurring for some of our function calls. 

"""

# ╔═╡ 78c56767-60ef-4373-9549-680d9531ba35
md"""
## Selecting columns
We could perform all the operations below on the full dataframes.  
Indeed, sometimes, it's easiest just to select all the columns.
(In this case, that's a suprising $(size(df_ps_raw,2)) columns!)
But, if we do, then we'll be making lots of copies of columns that we may have no intention of ever looking at. 
Those columns take up memory and will require addition memory allocations and transfers, slowing us down.  
Therefore, it's often wise to select just the columns that you intend to use (or think you might want to use).  
We can do that with the `select` function.
"""

# ╔═╡ 025a5caf-971b-4475-bbb2-692e49e90200
begin 
	cols_to_keep = [:pl_name, :sy_kepmag, :ra, :dec, :pl_orbper, :pl_rade, :pl_projobliq, :pl_projobliqerr1, :pl_projobliqerr2, :disc_facility, :gaia_id, :st_teff ]
	df_ps = select(df_ps_raw,cols_to_keep)
end

# ╔═╡ b3b7a9b6-2d65-4545-b806-0a97008ffec7
df_ps_hat = filter(row->row.disc_facility=="HATNet", df_ps);

# ╔═╡ 5798b895-848f-4115-86c5-d6a8a2e7eff8
df_ps_hat_w_rm1 = filter(row->!ismissing(row.pl_projobliq), df_ps_hat)

# ╔═╡ 7f3e1c8b-32eb-4548-94f3-5812cbd1320f
targetpos = (; ra = df_ps_hat.ra[1], dec = df_ps_hat.dec[1] )

# ╔═╡ a7c495bd-01e0-4812-959c-5c841d94be9e
df_ps_hat_w_rm2 = filter(row->row.disc_facility=="HATNet" && !ismissing(row.pl_projobliq), df_ps);

# ╔═╡ 9333b5fe-3527-482c-a885-30b4b919ba7a
@test isequal(df_ps_hat_w_rm1,df_ps_hat_w_rm2)

# ╔═╡ 0db75648-f44b-4b5a-b2c1-4caa946c3c2c
df_ps_raw[!,cols_to_keep];

# ╔═╡ 8127f39d-93d5-431a-a487-0c1c2c0d1372
md"""
Now, we can proceed to manipulate a much smaller DataFrame.
$(round(Base.summarysize(df_ps) / 1024^2,sigdigits=3)) MB instead of the $(round(Base.summarysize(df_ps_raw) / 1024^2,sigdigits=3)) MB for `df_raw`.
Even though, the full dataset would easily fit into any modern computer's RAM, it would be significantly bigger than size of the *cache*, a small, but faster portion of memory that can dramatically accelerate computations.
"""

# ╔═╡ f5ac5256-5e48-488d-91cf-2b169bfa36e5
begin
	kepler_names_table = "keplernames"
	url_get_keplernames_table = make_tap_query_url(nexsci_query_base_url, kepler_names_table)
end

# ╔═╡ 83bbbf1b-4809-4b12-a8a5-ba1f65e052f9
url_gaia_match_query = make_tap_query_url(gaia_query_base_url, "gaiadr3.gaia_source", where="1=contains(POINT($(targetpos.ra),$(targetpos.dec)),CIRCLE(ra,dec,30./3600.))", select_cols="*,DISTANCE(POINT($(targetpos.ra),$(targetpos.dec)),POINT(ra,dec))+AS+ang_sep",order_by_cols="ang_sep",max_rows=100)

# ╔═╡ afb9dd8e-d72a-4fea-8991-b77062d2c732
"""
`query_to_df(url)` downloads data from a URL and attempts to place it into a DataFrame
"""
query_to_df(url) = CSV.read(HTTP.get(url).body,DataFrame)

# ╔═╡ 3fc2a681-5254-4900-aea7-34eef7958f99
df_kepler_names = query_to_df(url_get_keplernames_table)

# ╔═╡ 6d21f84f-d0cb-4224-8b91-51acdb31e9bd
df_kepler_names

# ╔═╡ 1787a9ce-ae89-4e57-9c89-80b5e24bfb7f
df_ps_hat_and_kepler = innerjoin(df_ps_hat,df_kepler_names,on=:pl_name)

# ╔═╡ c52f0032-7c93-4139-9900-c0adf2fe1666
df_ps_hat_and_kepler[!, [:kepler_name,:kepid] ]

# ╔═╡ 76e2ad02-9a1d-43a1-93bf-92eceb7cf062
df_ps_hat_and_kepler[!, [:pl_name, :gaia_id] ]

# ╔═╡ d74f51d1-30d6-443c-9b92-58697be6045b
md"""
Now, we got a list of several objects that are quite close to our specified coordinates.  How can we tell which one is "right"?

A good starting point is to inspect the angular separation of each object to the specified coordinate and to compare the Gaia g magnitude to the Kepler magnitude of our intended target ($(df_ps_hat_and_kepler.sy_kepmag[1])).
"""

# ╔═╡ 4e2a9eae-df05-435b-a8ab-3766831ceb8f
begin
	df_ps_hat_and_kepler_inner = df_ps_hat_and_kepler
	df_ps_hat_and_kepler_left = leftjoin(df_ps_hat,df_kepler_names,on=:pl_name)
	df_ps_hat_and_kepler_right = rightjoin(df_ps_hat,df_kepler_names,on=:pl_name)
	df_ps_hat_and_kepler_outer = outerjoin(df_ps_hat,df_kepler_names,on=:pl_name)
end;

# ╔═╡ cae99a51-9a3c-4665-bf78-70752d26c7d6
begin
	# Since access via eval, need to tell Pluto that this cell depends on all the following dataframes
	df_ps_hat, df_kepler_names, df_ps_hat_and_kepler_inner, df_ps_hat_and_kepler_left, df_ps_hat_and_kepler_right, df_ps_hat_and_kepler_outer
	
	DataFrame(map(s->(;dataframe=s, num_rows=size(eval(s),1), num_cols=size(eval(s),2)),[:df_ps_hat,:df_kepler_names,:df_ps_hat_and_kepler_inner,:df_ps_hat_and_kepler_left,:df_ps_hat_and_kepler_right,:df_ps_hat_and_kepler_outer]))
end

# ╔═╡ a91fc636-644c-4860-9f28-2cd2f03a59af
begin
	response_3b_ref = innerjoin(
		filter(row->row.disc_facility=="TrES", df_ps)
		,df_kepler_names,
		on=:pl_name).kepid
end;

# ╔═╡ 986bd5f8-48b3-4652-8767-bd215fdc43cd
if ismissing(response_3b)
	still_missing()
elseif typeof(response_3b) != Vector{Int64}
	 wrong_type()
elseif !( isequal(response_3b,response_3b_ref) )
	keep_working()
else
	correct()
end

# ╔═╡ 19727360-360c-4d9e-a5f5-3dd320c07669
if do_gaia_queries
	df_gaia_near = query_to_df(url_gaia_match_query)
end

# ╔═╡ 55945bef-de16-4917-92f9-65422915c188
if do_gaia_queries
	df_gaia_near[!,[:designation,:ang_sep,:phot_g_mean_mag]]
end

# ╔═╡ 21eb8fa1-288b-424d-bf63-ff0fcb366735
"""`replace_spaces_for_tap(str)`

Replace spaces with +'s as expected for TAP queries.
"""
replace_spaces_for_tap(s::AbstractString) = replace(s," "=>"+")

# ╔═╡ 7abb430d-5a4c-45f4-9272-edbf89c07621
desig = replace_spaces_for_tap(df_ps_hat_and_kepler.gaia_id[1])

# ╔═╡ 704df669-56f7-4804-840d-349a862ae7dd
url_gaiadr2_query = make_tap_query_url(gaia_query_base_url, "gaiadr2.gaia_source", where="designation='$(desig)'",select_cols="*",max_rows=5)

# ╔═╡ 8e453879-008d-4dfd-85d8-93d338b5a659
if do_gaia_queries
	df_gaiadr2_hat7 = query_to_df(url_gaiadr2_query)
end

# ╔═╡ 767930b1-ede5-4f94-a75a-d528378fdea3
if do_gaia_queries
	url_gaiadr3_query = make_tap_query_url(gaia_query_base_url, "gaiadr3.gaia_source", where="source_id='$(df_gaiadr2_hat7.source_id[1])'",select_cols="*",max_rows=5)
end

# ╔═╡ dcc2a8d9-38e2-4c7a-a8b9-5b3f4c845b47
if do_gaia_queries
	df_gaiadr3_hat7 = query_to_df(url_gaiadr3_query)
end

# ╔═╡ 02c978d9-3bd0-4286-ad7b-e619789ec50f
if do_gaia_queries
	Markdown.parse("""
We can compare the parallax (and it's uncertainty) from DR2 ($(df_gaiadr2_hat7.parallax[1]) ±$(df_gaiadr2_hat7.parallax_error[1])) to the newer values from DR3 ($(df_gaiadr3_hat7.parallax[1]) ±$(df_gaiadr3_hat7.parallax_error[1])). 
If we were doing a detailed scientifc analysis, we might want to update the stellar properties based on the improved parallax.
""")
end

# ╔═╡ fff96331-a2ad-4243-8acc-2c869ff89633
begin
	""" 
	`select_cols_for_tap(cols)`

	Returns a string of comma-separated columns names from a vector of columns names (as either strings or symbols), for using in a TAP query.
	"""
	function select_cols_for_tap end
	select_cols_for_tap(cols_to_keep::AbstractVector{Symbol}) = select_cols_for_tap(string.(cols_to_keep)) #string(map(s->string(s) * "+", cols_to_keep)...)[1:end-1]
	select_cols_for_tap(cols_to_keep::AbstractVector{AS}) where {AS<:AbstractString} = string(map(s->s * ",", cols_to_keep)...)[1:end-1]
	select_cols_for_tap(col_to_keep::Symbol) = string(col_to_keep)
	select_cols_for_tap(col_to_keep::AbstractString) = col_to_keep
end


# ╔═╡ 1b724436-545d-4e52-b4bc-92d04eb3a59e
select_cols_for_tap(cols_to_keep)

# ╔═╡ 77202e5c-2986-4cbf-b8fe-eac0201b02ea
url_get_pl_w_rm_from_ps_table = make_tap_query_url(nexsci_query_base_url, planeary_systems_table, select_cols= select_cols_for_tap(cols_to_keep), where="pl_projobliq+is+not+null")

# ╔═╡ 08c9a7b7-e195-40da-a58e-28c9a5f221e4
df_pl_w_rm = query_to_df(url_get_pl_w_rm_from_ps_table)

# ╔═╡ 67ea55f3-391a-42a9-8735-7420fe75a16f
let
	plt = scatter(df_pl_w_rm.pl_orbper,df_pl_w_rm.pl_projobliq, label=:none, xlabel="Period (d)", ylabel = "λ (degrees)", xscale=:log10)
end

# ╔═╡ 39f6a723-8295-45dd-9940-32bf3db9d035
md"""
## Code for providing feedback
"""

# ╔═╡ b46b5c15-416c-481c-a89b-9429ccba551d
response_1a_ref = df_ps_raw[:,[:pl_name,:pl_orbper,:pl_rade,:ttv_flag,:sy_pnum,:disc_facility]];

# ╔═╡ 5810939f-5cab-4afe-938b-8efe69a9d17e
if ismissing(response_1a)
	still_missing()
elseif !isequal(response_1a,response_1a_ref)
	keep_working()
else
	correct()
end

# ╔═╡ 3b62fb24-a595-4ae8-85b4-4345efa65f61
df_ps_w_rm_ref = filter(row->!ismissing(row.pl_projobliq), df_ps);

# ╔═╡ 5926c4bc-b12b-4e11-802f-cd8293f3d24b
if ismissing(df_ps_w_rm)
	still_missing()
elseif !isequal(df_ps_w_rm,df_ps_w_rm_ref)
	keep_working()
else
	correct()
end

# ╔═╡ 5d5b44e0-d993-4d91-8189-772fad8d370e
md"""
When we filtered `df_raw` to find Rossiter-McLaughlin measurements, we found only $(size(df_ps_w_rm_ref,1)) measurements.  But the figures we saw in the reading and class show many more points than that.  Why is that?
"""

# ╔═╡ 080a8eab-6d4e-439e-b502-7a044621f4a7
df_pl_w_rm_by_disc_facility = groupby(df_ps_w_rm_ref,:disc_facility)

# ╔═╡ 252fc5c0-ffaa-4847-80a1-0c1c30d7291f
length(df_pl_w_rm_by_disc_facility)

# ╔═╡ e16167e0-4cd5-46e2-a315-0ad7b587e97e
map(key->key.disc_facility, keys(df_pl_w_rm_by_disc_facility))

# ╔═╡ 31732def-5494-4195-b4dd-1e09e2822513
combine(df_pl_w_rm_by_disc_facility, nrow)

# ╔═╡ 689e0476-ae76-406f-8687-5c70859aab3d
df_pl_w_rm_by_disc_facility[2]

# ╔═╡ 14a88a3d-8850-41b9-9c94-3ddca3223dd7
let
 	plt = plot(xlabel="P (d)", ylabel="λ (degrees)", color_palette=ColorSchemes.mk_15)
	for (i,k) in enumerate(keys(df_pl_w_rm_by_disc_facility))
		# Shorten the names appearing in the legend
		legend_str = k.disc_facility
		m = match(r"\((\S+)\)", legend_str)
		if !isnothing(m)
			legend_str = first(m)	
		end
		legend_str = replace(legend_str, "Anglo-Australian Telescope"=>"AAT")
		# Plot points from one observatory
		scatter!(plt, df_pl_w_rm_by_disc_facility[k].pl_orbper,  df_pl_w_rm_by_disc_facility[k].pl_projobliq, color=i, label=legend_str )
	end
	plt
end

# ╔═╡ e2ae7f02-b15a-43ff-a448-63b01ee5592d
let
	df = combine(df_pl_w_rm_by_disc_facility, nrow, :st_teff=>mean =>:mean_st_teff, :pl_rade=>mean)
	sort!(df,order(:nrow, rev=true) )
end

# ╔═╡ bd13b3c6-42d9-4e13-8815-c58a2861ea01
let
	df = combine(df_pl_w_rm_by_disc_facility, nrow, :st_teff=>mean_skipmissing =>:mean_st_teff, :pl_rade=>mean_skipmissing)
	sort!(df,order(:nrow, rev=true) )
end

# ╔═╡ b8b405e9-2bdd-46dc-baaa-d2e416d6b272
let 
	# Transform
	df1 = transform(df_ps_w_rm_ref, [:pl_projobliqerr1,:pl_projobliqerr2] => 
	ByRow((errhi,errlo) -> (abs(errhi)+abs(errlo))/2) => :pl_projobliqerr ) 
	
	transform!(df1, :disc_facility => 
	ByRow(x->string(replace(x,"Multiple Facilities"=>"Multiple Observatories"))) => :disc_facility ) 

	# Split
	df2 = groupby(df1, :disc_facility) 

	# Apply & Combine steps 
	df3 = combine(df2, nrow,
		:st_teff=>mean_skipmissing=>:st_teff_mean, 
		:pl_rade=>mean_skipmissing=>:pl_rade_mean, 
		:pl_projobliqerr=>mean_skipmissing=>:pl_projbobliqerr )
	
	sort!(df3,:nrow, rev=true)
end

# ╔═╡ 77a15db4-1482-4ffe-8704-33b88f4e69f8
let
	df1 = transform(df_ps_w_rm_ref, :pl_rade=> ByRow(x -> x>=6) => :is_giant )
	df2 = groupby(df1,:is_giant)	
	df3 = combine(df2, nrow, :st_teff=>mean_skipmissing=>:st_teff,
							 :pl_rade=>mean_skipmissing=>:pl_rade_mean,
		 				     :pl_projobliq =>mean_skipmissing=>:pl_projobliq_mean )
end

# ╔═╡ ec9d7ccb-1c6c-40e3-8bff-9ef02043dd20
df_ps_hatns_w_rm_ref = filter(row->(row.disc_facility=="HATNet" || row.disc_facility=="HATSouth") && !ismissing(row.pl_projobliq), df_ps);

# ╔═╡ b0452d6c-b6e8-4403-8b9c-6ff6b60b905d
if ismissing(df_ps_hatns_w_rm)
	still_missing()
elseif !isequal(df_ps_hatns_w_rm,df_ps_hatns_w_rm_ref)
	keep_working()
else
	correct()
end

# ╔═╡ 53553415-f7f3-4fbe-b657-a510fab9a619
begin
	local url_get_hatns_w_rm_ref = make_tap_query_url(
		nexsci_query_base_url, planeary_systems_table, 
		select_cols= select_cols_for_tap(cols_to_keep), 
		where="(disc_facility='HATNet'+or+disc_facility='HATSouth')+and+pl_projobliq+is+not+null")
	df_pl_hatns_w_rm_ref = query_to_df(url_get_hatns_w_rm_ref)
end;

# ╔═╡ 532c4ebc-f40a-43a2-aabd-d04d680bbca6
if ismissing(df_pl_hatns_w_rm)
	still_missing()
elseif !isequal(df_pl_hatns_w_rm,df_pl_hatns_w_rm_ref)
	keep_working()
else
	correct()
end


# ╔═╡ ec16e644-f64c-40cb-b7cc-5e6cfe132542
begin
	local df_tmp1 = filter(row->!ismissing(row.st_teff), df_ps_w_rm_ref)
	local df_tmp2 = transform(df_tmp1, :st_teff => ByRow(round_to_nearest_600) => :st_teff_bin )
	local df_tmp3 = groupby(df_tmp2, :st_teff_bin)
	df_pl_w_rm_by_teff_ref = combine(df_tmp3, nrow, :st_teff=>mean, 
		:pl_rade=>mean,
		:pl_rade=>std, 
		:pl_projobliq=>(x->mean(abs.(x)))=>:pl_projobliq_mean_abs, 
		:pl_projobliq=>(x->std(abs.(x)))=>:pl_projobliq_std_abs ) 
	 sort!(df_pl_w_rm_by_teff_ref,:st_teff_bin)
end;

# ╔═╡ de48a078-ef90-4429-b37e-8bc45e10a825
if !@isdefined(df_pl_w_rm_by_teff)
	not_defined(:df_pl_w_rm_by_teff)
elseif ismissing(df_pl_w_rm_by_teff)  
	still_missing()  
elseif "st_teff_mean" ∉ names(df_pl_w_rm_by_teff)
	keep_working(md"Your dataframe doesn't contain a column named `st_teff_mean`.")
elseif "pl_rade_mean" ∉ names(df_pl_w_rm_by_teff)
	keep_working(md"Your dataframe doesn't contain a column named `pl_rade_mean`.")
elseif "pl_rade_std" ∉ names(df_pl_w_rm_by_teff)
	keep_working(md"Your dataframe doesn't contain a column named `pl_rade_std`.")
elseif "pl_projobliq_mean_abs" ∉ names(df_pl_w_rm_by_teff)
	keep_working(md"Your dataframe doesn't contain a column named `pl_projobliq_mean_abs`.")
elseif "pl_projobliq_mean_abs" ∉ names(df_pl_w_rm_by_teff)
	keep_working(md"Your dataframe doesn't contain a column named `pl_projobliq_std_abs`.")
elseif size(df_pl_w_rm_by_teff) != size(df_pl_w_rm_by_teff_ref)
	keep_working(md"The size of your dataframe doesn't match what is expected.  Maybe you're computing some extra columns?")
elseif !issorted(df_pl_w_rm_by_teff.st_teff_bin)
	keep_working(md"Your dataframe isn't sorted correctly.")
else
	mask_cols_match = map(n->all(isapprox.(df_pl_w_rm_by_teff[!,n], df_pl_w_rm_by_teff_ref[!,n], nans=true)),names(df_pl_w_rm_by_teff_ref))
	if !all(mask_cols_match)
		keep_working(md"""Your dataframe has different values in the following columns: $(string(names(df_pl_w_rm_by_teff_ref)[.!mask_cols_match])).  
		It's possible that you're results are correct, and just differ in some trivial way.  But it's also possible something is wrong.  You may want to manually compare your results to the data in `df_pl_w_rm_by_teff_ref` to see if you notice any significant differences.""")
	else
		correct()
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Query = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
CSV = "~0.10.4"
ColorSchemes = "~3.19.0"
DataFrames = "~1.3.6"
HTTP = "~1.4.0"
Plots = "~1.31.7"
PlutoTeachingTools = "~0.2.3"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.43"
Query = "~1.0.0"
StatsBase = "~0.33.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "811b51afa0a9712e0e8e4bcd844687a08442f7f0"

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

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "84259bb6172806304b9101094a7cc4bc6f56dbc6"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.5"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

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

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

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

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

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

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

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

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

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
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "cf0a9940f250dc3cb6cc6c6821b4bf8a4286cf9c"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.66.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "bc9f7725571ddb4ab2c4bc74fa397c1c5ad08943"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.69.1+0"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "fb28b5dc239d0174d7297310ef7b84a11804dfab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.0.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "12a584db96f1d460421d5fb8860822971cdb8455"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.4"

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

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "d19f9edd8c34760dca2de2b503f969d8700ed288"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.4"

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

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IterableTables]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Requires", "TableTraits", "TableTraitsUtils"]
git-tree-sha1 = "70300b876b2cebde43ebc0df42bc8c94a144e1b4"
uuid = "1c8ee90f-4401-5389-894e-7a04a3dc0f4d"
version = "1.0.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "a19652399f43938413340b2068e11e55caa46b65"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.31.7"

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

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "2777a5c2c91b3145f5aa75b61bb4c2eb38797136"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.43"

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

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.Query]]
deps = ["DataValues", "IterableTables", "MacroTools", "QueryOperators", "Statistics"]
git-tree-sha1 = "a66aa7ca6f5c29f0e303ccef5c8bd55067df9bbe"
uuid = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
version = "1.0.0"

[[deps.QueryOperators]]
deps = ["DataStructures", "DataValues", "IteratorInterfaceExtensions", "TableShowUtils"]
git-tree-sha1 = "911c64c204e7ecabfd1872eb93c49b4e7c701f02"
uuid = "2aef5ad7-51ca-5a8f-8e88-e75cf067b44b"
version = "0.9.3"

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
git-tree-sha1 = "22c5201127d7b243b9ee1de3b43c408879dff60f"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.3.0"

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

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "c0f56940fc967f3d5efed58ba829747af5f8b586"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.15"

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

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArraysCore", "Tables"]
git-tree-sha1 = "8c6ac65ec9ab781af05b08ff305ddc727c25f680"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.12"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableShowUtils]]
deps = ["DataValues", "Dates", "JSON", "Markdown", "Test"]
git-tree-sha1 = "14c54e1e96431fb87f0d2f5983f090f1b9d06457"
uuid = "5e66a065-1f0a-5976-b372-e0b8c017ca10"
version = "0.2.5"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

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

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

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

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

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
# ╟─df95d06f-29c8-44b6-8def-556ca63bc1eb
# ╟─78846201-8190-4ebe-845c-9d8fc92b805a
# ╟─6e9d46e2-752b-4d84-aec8-c39232a2aed3
# ╟─1cce5341-4e39-4110-8b97-f570154400a9
# ╟─245c4d7b-d648-4f39-be46-82070c062b86
# ╟─67be8932-7625-4e83-b42d-9928e36c74c4
# ╟─bf780106-afd3-4e26-8673-d5c27953c125
# ╠═955eaada-b7c0-41dc-b6a7-e9441ba45404
# ╟─3c58158d-183b-4224-af8f-c50289c7bcbe
# ╟─20c76a9c-a759-410b-8ef3-d86bb7640f54
# ╠═d8936c55-4c06-43fc-9d0a-a621d919caab
# ╟─63c702da-ad9d-4e31-ad26-39e9f12f2061
# ╠═acf3dd12-7187-4967-bc01-954ec8706bc6
# ╟─35440dd6-bb8b-499e-99d9-cb6cc03ccc67
# ╟─223e5bf8-649a-411b-ad9e-78a4e911d402
# ╟─bb83b685-8aeb-4dd5-ab61-b6ae0e804d07
# ╠═f5ac5256-5e48-488d-91cf-2b169bfa36e5
# ╠═3fc2a681-5254-4900-aea7-34eef7958f99
# ╟─2526fd77-82d2-4a9e-8e41-a5076dc073f0
# ╟─78c56767-60ef-4373-9549-680d9531ba35
# ╠═025a5caf-971b-4475-bbb2-692e49e90200
# ╟─f9eb814e-923c-44a2-9b50-f1058db26258
# ╠═0db75648-f44b-4b5a-b2c1-4caa946c3c2c
# ╟─8127f39d-93d5-431a-a487-0c1c2c0d1372
# ╟─69718757-73c7-4dc3-a075-478db7d05722
# ╠═9105b929-ad4b-48f7-b234-2bab6f3bd524
# ╟─5810939f-5cab-4afe-938b-8efe69a9d17e
# ╟─525c5db3-7e7e-466c-a2b8-1b6d40d5bd64
# ╟─4b10f695-5d1c-4072-9d4e-de194db5cdd5
# ╠═b3b7a9b6-2d65-4545-b806-0a97008ffec7
# ╟─fc77ed7a-d9d3-40dd-adee-502a2226a7c4
# ╟─7b2d6692-5a17-465f-a279-3a7c81d33949
# ╠═5798b895-848f-4115-86c5-d6a8a2e7eff8
# ╟─ea8e29a2-aea5-43da-b72a-a9632dda3078
# ╟─d6844a2b-7bf1-4cec-951a-79a5acb205c5
# ╠═a7c495bd-01e0-4812-959c-5c841d94be9e
# ╟─7d33a883-1d99-4203-a9db-b13b9d659b79
# ╠═9333b5fe-3527-482c-a885-30b4b919ba7a
# ╟─5ddbe9e6-a2aa-4c4f-875c-40cbbc87698d
# ╟─6b562c9a-121d-4314-818c-751d4f99e186
# ╠═58aba1d9-5605-4dc7-a613-ffe587a723d0
# ╟─5926c4bc-b12b-4e11-802f-cd8293f3d24b
# ╟─fc4a26b6-1325-47ac-9aa8-949343723eff
# ╠═1e81f5ee-5a7e-4777-8f17-b4cc7554b467
# ╟─b0452d6c-b6e8-4403-8b9c-6ff6b60b905d
# ╟─f21b46ad-a293-486b-bafd-24245a3d1511
# ╟─5d5b44e0-d993-4d91-8189-772fad8d370e
# ╟─93fff29b-e854-4e7f-99dc-89af1d3b625a
# ╟─3ecce2ce-adc7-4ea1-b22f-bd9182f5a39a
# ╠═1b724436-545d-4e52-b4bc-92d04eb3a59e
# ╠═77202e5c-2986-4cbf-b8fe-eac0201b02ea
# ╠═08c9a7b7-e195-40da-a58e-28c9a5f221e4
# ╟─636530dc-146b-4900-a79b-ca66cb4c1e12
# ╠═67ea55f3-391a-42a9-8735-7420fe75a16f
# ╟─0365f044-2533-4580-926c-07e5ebd93ea7
# ╠═183cffd3-db02-4ba9-86bf-5af28d84cd3b
# ╟─532c4ebc-f40a-43a2-aabd-d04d680bbca6
# ╟─4e065419-b812-42af-a48e-830ac222be87
# ╟─533517f8-7db7-44a4-ae1c-a435ba4df597
# ╠═6d21f84f-d0cb-4224-8b91-51acdb31e9bd
# ╟─c88ebf43-3a11-4416-b36b-e489a8b16f84
# ╠═1787a9ce-ae89-4e57-9c89-80b5e24bfb7f
# ╟─8dd3e6d6-c4c4-498b-a917-c1da1938fb07
# ╠═c52f0032-7c93-4139-9900-c0adf2fe1666
# ╟─7b937404-c3c1-4d58-9a07-3c150d14fcc0
# ╠═4e2a9eae-df05-435b-a8ab-3766831ceb8f
# ╟─cae99a51-9a3c-4665-bf78-70752d26c7d6
# ╟─32db9a7b-ffbf-44d1-a4b5-fa3ecc2d4098
# ╠═db83d146-6954-4b40-9a43-668a5a23aa91
# ╟─e1e7c565-aea3-46ce-aa31-c4268a27f5f6
# ╟─b2296ab5-c687-47a3-b5a1-0f458d1407ed
# ╠═773bd2c2-8276-462c-ac4f-219624101743
# ╟─986bd5f8-48b3-4652-8767-bd215fdc43cd
# ╟─a91fc636-644c-4860-9f28-2cd2f03a59af
# ╟─19fc6a33-c0aa-4a14-b666-365e943e5c30
# ╟─2c18f37c-91da-40d6-aadc-248e86ca7641
# ╟─6dc8da29-aee5-404b-a746-5fca244f5956
# ╟─f2dbf301-a4ee-46b4-b927-a490e22ff4f1
# ╠═faab8c3e-b557-4db0-99a3-730e2ec582e2
# ╟─a8e723f4-1f20-478e-9617-e022f239fece
# ╟─90190fe3-4fff-4be9-b494-b249b1f97092
# ╠═76e2ad02-9a1d-43a1-93bf-92eceb7cf062
# ╟─e9b0320a-aa7f-4afe-9018-25d4ca45ac55
# ╠═7abb430d-5a4c-45f4-9272-edbf89c07621
# ╟─07845a5c-5a2c-48a4-96fe-a176d709ea5a
# ╠═704df669-56f7-4804-840d-349a862ae7dd
# ╟─b865f025-f0cd-4713-a1da-2a57ac3cb997
# ╠═8e453879-008d-4dfd-85d8-93d338b5a659
# ╟─f7d8fc30-b6fa-4122-81c9-a0868fdfefde
# ╠═767930b1-ede5-4f94-a75a-d528378fdea3
# ╠═dcc2a8d9-38e2-4c7a-a8b9-5b3f4c845b47
# ╟─02c978d9-3bd0-4286-ad7b-e619789ec50f
# ╟─6ad9be57-c8e7-4590-9b96-7c3a043c20ad
# ╠═7f3e1c8b-32eb-4548-94f3-5812cbd1320f
# ╠═83bbbf1b-4809-4b12-a8a5-ba1f65e052f9
# ╠═19727360-360c-4d9e-a5f5-3dd320c07669
# ╟─d74f51d1-30d6-443c-9b92-58697be6045b
# ╠═55945bef-de16-4917-92f9-65422915c188
# ╟─c75786ee-55b8-4ff6-bb99-d9faa738a01f
# ╠═a0c53b5e-76ce-428e-bbef-14e09f10ba51
# ╟─5ba92ea8-a92f-4c7e-9a3a-cc7b3fd11585
# ╟─694b1c23-be91-42fa-a20a-69305c117557
# ╟─8a5200d0-65f6-4be0-b923-c4dbcc3b6330
# ╠═080a8eab-6d4e-439e-b502-7a044621f4a7
# ╟─83a7592d-505d-434d-9810-07bf07cac5fa
# ╠═252fc5c0-ffaa-4847-80a1-0c1c30d7291f
# ╟─e16167e0-4cd5-46e2-a315-0ad7b587e97e
# ╟─a172c8ec-6895-491f-95c2-54fbd524da0a
# ╠═31732def-5494-4195-b4dd-1e09e2822513
# ╟─a4c12bae-15d9-45bd-80a0-b62225a1487e
# ╠═689e0476-ae76-406f-8687-5c70859aab3d
# ╟─824b2f54-0cab-4685-bc06-8d3bef3d18f5
# ╠═14a88a3d-8850-41b9-9c94-3ddca3223dd7
# ╟─280ae58d-882b-44aa-a24d-dd3dea1eaacb
# ╟─6bea5705-8898-4ecb-9382-392f9ce79660
# ╠═e2ae7f02-b15a-43ff-a448-63b01ee5592d
# ╟─95cd722f-0b05-44ec-9a3f-12afa0ee9d2a
# ╠═67ad9808-ccf9-4b9d-87c0-95ba18c26eef
# ╠═bd13b3c6-42d9-4e13-8815-c58a2861ea01
# ╟─56aeecf1-34d3-4dfa-a226-cc15b1d82072
# ╟─bf75cf8b-77b3-46a4-a8cb-95d551d51241
# ╠═b8b405e9-2bdd-46dc-baaa-d2e416d6b272
# ╟─54a1df20-0d15-4a08-86db-6df23e0f7246
# ╠═77a15db4-1482-4ffe-8704-33b88f4e69f8
# ╟─5179edd7-84e8-4161-942b-8036c6984b8b
# ╠═4c67c356-e198-42d1-8a34-991cd82eed56
# ╠═d0e15021-afb0-48b4-9b25-ff0e84074024
# ╟─de48a078-ef90-4429-b37e-8bc45e10a825
# ╟─f02ae91c-4588-4840-a2f2-b6039cf5f222
# ╠═ab27b832-55dd-4ff7-9692-920a7f0daa4d
# ╠═2f4172bd-ebd5-4db2-81f4-c30ba339ffd9
# ╟─8a4ce3c9-a120-41c1-b964-4930d2f04a29
# ╟─341035c9-7300-4fa0-90c2-3700f853c865
# ╠═aaa8f0d3-ac73-44b9-a630-eea5671a8f0f
# ╠═d68a116b-83e3-43a0-8483-399eacbe9a76
# ╠═7e39535a-19ab-4b0a-823a-aec792895c68
# ╟─be348711-98f9-4654-ac90-3e5fc893a5e2
# ╟─6bc2a24b-92c5-490d-895e-2c3eabfc3db7
# ╟─afb9dd8e-d72a-4fea-8991-b77062d2c732
# ╟─21eb8fa1-288b-424d-bf63-ff0fcb366735
# ╟─fff96331-a2ad-4243-8acc-2c869ff89633
# ╟─39f6a723-8295-45dd-9940-32bf3db9d035
# ╟─b46b5c15-416c-481c-a89b-9429ccba551d
# ╟─3b62fb24-a595-4ae8-85b4-4345efa65f61
# ╟─ec9d7ccb-1c6c-40e3-8bff-9ef02043dd20
# ╟─53553415-f7f3-4fbe-b657-a510fab9a619
# ╟─ec16e644-f64c-40cb-b7cc-5e6cfe132542
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
