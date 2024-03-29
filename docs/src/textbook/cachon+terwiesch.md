```@raw html
<style>
    table {
        display: table !important;
        margin: 2rem auto !important;
        border-top: 2pt solid rgba(0,0,0,0.2);
        border-bottom: 2pt solid rgba(0,0,0,0.2);
    }

    pre, div {
        margin-top: 1.4rem !important;
        margin-bottom: 1.4rem !important;
    }

    .code-output {
        padding: 0.7rem 0.5rem !important;
    }

    .admonition-body {
        padding: 0em 1.25em !important;
    }
</style>

<!-- PlutoStaticHTML.Begin -->
<!--
    # This information is used for caching.
    [PlutoStaticHTML.State]
    input_sha = "397ef844733a8471a9f3f06785ba45879b22fbfd8d921e59d774987f0b9684d3"
    julia_version = "1.7.1"
-->

<div class="markdown"><p>This notebook illustrates the usage of <a href="https://github.com/frankhuettner/NewsvendorModel.jl">NewsvendorModel.jl</a> with examples from the <strong>excellent textbook by <a href="http://cachon-terwiesch.net/3e/index.php">Cachon &amp; Terwiesch &#40;3rd</a></strong> or <a href="https://www.mheducation.com/highered/product/matching-supply-demand-introduction-operations-management-cachon-terwiesch/M9780078096655.html">4th</a> edition&#41;.</p>
<p>These notes are not self-contained but should be considered as a companion to the above text book.</p>
</div>


<div class="markdown"><p>You can load this notebook in <a href="https://github.com/fonsp/Pluto.jl">Pluto</a> from here: <a href="https://github.com/frankhuettner/NewsvendorModel.jl/blob/main/docs/src/textbook/cachon&#37;2Bterwiesch.jl">https://github.com/frankhuettner/NewsvendorModel.jl/blob/main/docs/src/textbook/cachon&#37;2Bterwiesch.jl</a></p>
</div>


```
## ONeill Hammer 3/2
```@raw html
<div class="markdown">

<p>The leading case of the book is about the <strong>O&#39;Neill Hammer 3/2</strong>, with the following information &#40;for a detailed treatment, it is referred to the sources below&#41;.</p>
<p>Unit values:</p>
<ul>
<li><p>cost per unit ordered &#61; 110</p>
</li>
<li><p>selling price per unit &#61; 190</p>
</li>
<li><p>salvage value &#61; 190</p>
</li>
</ul>
<p>Demand distribution:</p>
<ul>
<li><p>expected demand &#61; 3192</p>
</li>
<li><p>standard deviation of demand &#61; 1181</p>
</li>
</ul>
</div>

<pre class='language-julia'><code class='language-julia'># Load the packages needed
using NewsvendorModel, Distributions</code></pre>


<pre class='language-julia'><code class='language-julia'># Define the model
oneill = NVModel(cost = 110, 
                 price = 190, 
                 salvage = 90, 
                 demand = Normal(3192, 1181)
         )</code></pre>
<pre id='var-oneill' class='code-output documenter-example-output'>Data of the Newsvendor Model
 * Demand distribution: Normal{Float64}(μ=3192.0, σ=1181.0)
 * Unit cost: 110.00
 * Unit selling price: 190.00
 * Unit salvage value: 90.00
</pre>

<pre class='language-julia'><code class='language-julia'># Solve the model
solve(oneill)</code></pre>
<pre id='var-hash139011' class='code-output documenter-example-output'>=====================================
Results of maximizing expected profit
 * Optimal quantity: 4186 units
 * Expected profit: 222296.50
=====================================
This is a consequence of
 * Cost of underage:  80.00
   ╚ + Price:               190.00
   ╚ - Cost:                110.00
 * Cost of overage:   20.00
   ╚ + Cost:                110.00
   ╚ - Salvage value:       90.00
 * Critical fractile: 0.80
 * Rounded to closest integer: true
-------------------------------------
Ordering the optimal quantity yields
 * Expected sales: 3060.16 units
 * Expected lost sales: 131.84 units
 * Expected leftover: 1125.84 units
 * Expected salvage revenue: 101325.15
-------------------------------------
</pre>


<div class="markdown"><p>Note that the result is slightly different from the textbook, which suggests the order quantity 4,184 &#40;instead of 4,186&#41;. This is due to rounding errors in the textbook.</p>
<h3>2-stage calculation</h3>
<p>The authors also consider the scenario in which it is possible to make a second order later during the selling period &#40;what follows is very brief and I recommend looking up the book&#41;. It is assumed that </p>
<ul>
<li><p>the unit cost for the second order are 20&#37; higher ⇒ 20&#37; * 110 &#61; 22. Yet, </p>
</li>
<li><p>demand for the rest of the season is assumed to be certain at that stage;</p>
</li>
<li><p>the reorder stage is early enough to ensure that we have enough units until we receive our second delivery</p>
</li>
</ul>
<p>Now there are two decision points: </p>
<ol>
<li><p>How many units to order prior to the season starts.</p>
</li>
<li><p>How many units to order at the second stage.</p>
</li>
</ol>
<p>To find the optimal order quantity for &#40;1&#41;, we think of the product as follows:</p>
<ul>
<li><p>Having a unit leftover is effectively loosing Cₒ &#61; 20</p>
</li>
<li><p>Having a unit too little is creating not such a heavy damage anymore; instead, we can save the day be ordering remaining demand at the second stage, albeit at a worse price ⇒ we miss out Cᵤ &#61; 22</p>
</li>
</ul>
<p>This is as if we had a product traded for zero cost and zero price, but having a unit left over costs 20 ⇒ salvage &#61; -20 ⇒ Cₒ &#61; 20. Being short a unit costs a backorder penalty of 22 ⇒ Cᵤ &#61; 22.</p>
</div>

<pre class='language-julia'><code class='language-julia'>oneill_1st_order_calculation = NVModel( demand = Normal(3192, 1181),
                                        cost = 0, 
                                        price = 0, 
                                        salvage = -20, 
                                        backorder = 22,
                                        )</code></pre>
<pre id='var-oneill_1st_order_calculation' class='code-output documenter-example-output'>Data of the Newsvendor Model
 * Demand distribution: Normal{Float64}(μ=3192.0, σ=1181.0)
 * Unit cost: 0.00
 * Unit selling price: 0.00
 * Unit salvage value: -20.00
 * Unit backorder penalty: 22.00
</pre>


<div class="markdown"><p>This yields the following critical fractile for the 1st stage:</p>
</div>

<pre class='language-julia'><code class='language-julia'>critical_fractile(oneill_1st_order_calculation)</code></pre>
<pre id='var-hash302985' class='code-output documenter-example-output'>0.5238095238095238</pre>


<div class="markdown"><p>This yields the following optimal order quantity for the 1st stage:</p>
</div>

<pre class='language-julia'><code class='language-julia'>q_opt(oneill_1st_order_calculation)</code></pre>
<pre id='var-hash633724' class='code-output documenter-example-output'>3263</pre>


<div class="markdown"><p>Ordering 3263 units results in the following expected lost sales, which is the expected order quantity for the second order:</p>
</div>

<pre class='language-julia'><code class='language-julia'>lost_sales(oneill, 3263)</code></pre>
<pre id='var-hash116048' class='code-output documenter-example-output'>436.502002733936</pre>


<div class="markdown"><p>Ordering 3263 further yields the following expected profit &#40;based on original unit values&#41;:</p>
</div>

<pre class='language-julia'><code class='language-julia'>profit(oneill, 3263)</code></pre>
<pre id='var-hash924210' class='code-output documenter-example-output'>210289.7997266064</pre>


<div class="markdown"><p>In total, this promises the following expected profit:</p>
</div>

<pre class='language-julia'><code class='language-julia'>profit(oneill, 3263) + lost_sales(oneill, 3263) * (190 - 132)</code></pre>
<pre id='var-hash970018' class='code-output documenter-example-output'>235606.9158851747</pre>


```
## Selected Exercises
```@raw html
<div class="markdown">

<p>The book offers exercises with solutions. Here is a small selection that illustrates the convinience of Distributions.jl and NewsvendorModel.jl &#40;everything is very brief and a detailed explanation can be found in the book&#41;.</p>
<h3>McClure Books</h3>
</div>

<pre class='language-julia'><code class='language-julia'># Define demand 
mcclure_demand = Normal(200, 80)</code></pre>
<pre id='var-mcclure_demand' class='code-output documenter-example-output'>Normal{Float64}(μ=200.0, σ=80.0)</pre>

<pre class='language-julia'><code class='language-julia'># Define model
mcclure_nvm = NVModel(cost = 12, price = 20, salvage = 12 - 4,demand = mcclure_demand)</code></pre>
<pre id='var-mcclure_nvm' class='code-output documenter-example-output'>Data of the Newsvendor Model
 * Demand distribution: Normal{Float64}(μ=200.0, σ=80.0)
 * Unit cost: 12.00
 * Unit selling price: 20.00
 * Unit salvage value: 8.00
</pre>


<div class="markdown"><h5>a&#41; Pr&#91;demand &gt; 400&#93;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>1 - cdf(mcclure_demand, 400)</code></pre>
<pre id='var-hash146432' class='code-output documenter-example-output'>0.006209665325776159</pre>


<div class="markdown"><h5>b&#41; Pr&#91;demand &lt; 100&#93;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>cdf(mcclure_demand, 100)</code></pre>
<pre id='var-hash977228' class='code-output documenter-example-output'>0.10564977366685525</pre>


<div class="markdown"><h5>c&#41; Pr&#91;160 &lt; demand &lt; 240&#93;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>cdf(mcclure_demand, 240) - cdf(mcclure_demand, 160)</code></pre>
<pre id='var-hash154150' class='code-output documenter-example-output'>0.38292492254802624</pre>


<div class="markdown"><h5>d&#41; Pr&#91;160 &lt; demand &lt; 240&#93;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>q_opt(mcclure_nvm)</code></pre>
<pre id='var-hash760803' class='code-output documenter-example-output'>234</pre>


<div class="markdown"><h5>e&#41; Quantity such that Pr&#91;demand ≤ q&#93; &#61; 95&#37;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>quantile(mcclure_demand, 0.95)</code></pre>
<pre id='var-hash328966' class='code-output documenter-example-output'>331.58829015611775</pre>


<div class="markdown"><h5>f&#41;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>1 - 0.95</code></pre>
<pre id='var-hash174229' class='code-output documenter-example-output'>0.050000000000000044</pre>


<div class="markdown"><h5>g&#41; Profit if q &#61; 300</h5>
</div>

<pre class='language-julia'><code class='language-julia'>profit(mcclure_nvm, 300)</code></pre>
<pre id='var-hash841200' class='code-output documenter-example-output'>1151.4366064267651</pre>


<div class="markdown"><h3>EcoTable Tea</h3>
</div>

<pre class='language-julia'><code class='language-julia'># Define demand 
ecotable_demand = Poisson(4.5)</code></pre>
<pre id='var-ecotable_demand' class='code-output documenter-example-output'>Poisson{Float64}(λ=4.5)</pre>

<pre class='language-julia'><code class='language-julia'># Define model
ecotable_nvm = NVModel(cost = 32, price = 55, salvage = 20, demand = ecotable_demand)</code></pre>
<pre id='var-ecotable_nvm' class='code-output documenter-example-output'>Data of the Newsvendor Model
 * Demand distribution: Poisson{Float64}(λ=4.5)
 * Unit cost: 32.00
 * Unit selling price: 55.00
 * Unit salvage value: 20.00
</pre>


<div class="markdown"><h5>a&#41; Pr&#91;demand &gt; 3&#93;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>1 - cdf(ecotable_demand, 3)</code></pre>
<pre id='var-hash128227' class='code-output documenter-example-output'>0.657704044165409</pre>


<div class="markdown"><h5>b&#41; Pr&#91;demand &lt; 7&#93;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>cdf(ecotable_demand, 7)</code></pre>
<pre id='var-hash791331' class='code-output documenter-example-output'>0.9134135283526439</pre>


<div class="markdown"><h5>c&#41; Optimal order quantity</h5>
</div>

<pre class='language-julia'><code class='language-julia'>q_opt(ecotable_nvm)</code></pre>
<pre id='var-hash173790' class='code-output documenter-example-output'>5</pre>


<div class="markdown"><h5>d&#41; Expected sales at q &#61; 4</h5>
</div>

<pre class='language-julia'><code class='language-julia'>sales(ecotable_nvm, 4)</code></pre>
<pre id='var-hash431037' class='code-output documenter-example-output'>3.411917495756798</pre>


<div class="markdown"><h5>d&#41; Expected leftover at q &#61; 6</h5>
</div>

<pre class='language-julia'><code class='language-julia'>leftover(ecotable_nvm, 6)</code></pre>
<pre id='var-hash958048' class='code-output documenter-example-output'>1.8231165154787454</pre>


<div class="markdown"><h5>f&#41; Smallest quantity q such that Pr&#91;demand ≤ q&#93; ≥ 90&#37;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>quantile(ecotable_demand, 0.90)</code></pre>
<pre id='var-hash624688' class='code-output documenter-example-output'>7</pre>


<div class="markdown"><h5>d&#41; Expected profit at q &#61; 8</h5>
</div>

<pre class='language-julia'><code class='language-julia'>profit(ecotable_nvm, 8)</code></pre>
<pre id='var-hash981521' class='code-output documenter-example-output'>59.13467821051198</pre>


<div class="markdown"><h3>Pony Express</h3>
</div>


<div class="markdown"><p>First we define the demand:</p>
</div>

<pre class='language-julia'><code class='language-julia'>xs = vec([5_000	10_000	15_000	20_000	25_000	30_000	35_000	40_000	45_000	50_000	55_000	60_000	65_000	70_000	75_000])</code></pre>
<pre id='var-xs' class='code-output documenter-example-output'>15-element Vector{Int64}:
  5000
 10000
 15000
 20000
 25000
 30000
 35000
     ⋮
 50000
 55000
 60000
 65000
 70000
 75000</pre>

<pre class='language-julia'><code class='language-julia'>ps = vec([0.0181	0.0733	0.1467	0.1954	0.1954	0.1563	0.1042	0.0595	0.0298	0.0132	0.0053	0.0019	0.0006	0.0002	0.0001])</code></pre>
<pre id='var-ps' class='code-output documenter-example-output'>15-element Vector{Float64}:
 0.0181
 0.0733
 0.1467
 0.1954
 0.1954
 0.1563
 0.1042
 ⋮
 0.0132
 0.0053
 0.0019
 0.0006
 0.0002
 0.0001</pre>

<pre class='language-julia'><code class='language-julia'># The distribution is nonparametric
elvis_demand = DiscreteNonParametric(xs,ps)</code></pre>
<pre id='var-elvis_demand' class='code-output documenter-example-output'>DiscreteNonParametric{Int64, Float64, Vector{Int64}, Vector{Float64}}(
support: [5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000, 65000, 70000, 75000]
p: [0.0181, 0.0733, 0.1467, 0.1954, 0.1954, 0.1563, 0.1042, 0.0595, 0.0298, 0.0132, 0.0053, 0.0019, 0.0006, 0.0002, 0.0001]
)
</pre>

<pre class='language-julia'><code class='language-julia'># Define model
elvis_nvm  = NVModel(cost = 6, price = 12, demand = elvis_demand, salvage = 2.5)</code></pre>
<pre id='var-elvis_nvm' class='code-output documenter-example-output'>Data of the Newsvendor Model
 * Demand distribution: DiscreteNonParametric{Int64, Float64, Vector{Int64}, Vector{Float64}}(
support: [5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000, 65000, 70000, 75000]
p: [0.0181, 0.0733, 0.1467, 0.1954, 0.1954, 0.1563, 0.1042, 0.0595, 0.0298, 0.0132, 0.0053, 0.0019, 0.0006, 0.0002, 0.0001]
)

 * Unit cost: 6.00
 * Unit selling price: 12.00
 * Unit salvage value: 2.50
</pre>


<div class="markdown"><h5>a&#41;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>cdf(elvis_demand, 30_000)</code></pre>
<pre id='var-hash735646' class='code-output documenter-example-output'>0.7852</pre>


<div class="markdown"><h5>b&#41;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>q_opt(elvis_nvm)</code></pre>
<pre id='var-hash427089' class='code-output documenter-example-output'>30000</pre>


<div class="markdown"><h5>c&#41;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>quantile(elvis_demand, 0.9)</code></pre>
<pre id='var-hash181951' class='code-output documenter-example-output'>40000</pre>


<div class="markdown"><h5>d&#41;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>leftover(elvis_nvm, 50_000)</code></pre>
<pre id='var-hash110038' class='code-output documenter-example-output'>25061.0</pre>


<div class="markdown"><h5>e&#41;</h5>
</div>

<pre class='language-julia'><code class='language-julia'>quantile(elvis_demand, 1.0) </code></pre>
<pre id='var-hash127500' class='code-output documenter-example-output'>75000</pre>

<pre class='language-julia'><code class='language-julia'>profit(elvis_nvm, 75_000) </code></pre>
<pre id='var-hash845649' class='code-output documenter-example-output'>-25000.0</pre>


<div class="markdown"><p>The answer in the book appears to be confusing: IMHO lost sales &#61; 0 if 75,000 wigs are ordered.</p>
</div>


<div class="markdown"><h3>Flextrola</h3>
<p>We just investigate part <strong>&#40;j&#41;</strong>: Variation with log normal demand</p>
</div>

<pre class='language-julia'><code class='language-julia'># Parameter σ² of log normal distribution from mean= 1000 and standard deviation = 600
σ² = log(1 + 600^2 / 1000^2)</code></pre>
<pre id='var-σ²' class='code-output documenter-example-output'>0.30748469974796055</pre>

<pre class='language-julia'><code class='language-julia'># Parameter μ of log normal distribution from mean = 1000 and standard deviation = 600
μ = log(1000^2 / √(600^2 + 1000^2))</code></pre>
<pre id='var-μ' class='code-output documenter-example-output'>6.754012929108157</pre>

<pre class='language-julia'><code class='language-julia'>flextrola_demand = LogNormal(μ, √σ²)</code></pre>
<pre id='var-flextrola_demand' class='code-output documenter-example-output'>LogNormal{Float64}(μ=6.754012929108157, σ=0.5545130293761911)</pre>

<pre class='language-julia'><code class='language-julia'># Indeed, the parameters yield the desired mean
mean(flextrola_demand)</code></pre>
<pre id='var-hash473563' class='code-output documenter-example-output'>999.9999999999998</pre>

<pre class='language-julia'><code class='language-julia'># Indeed, the parameters yield the standard deviation
std(flextrola_demand)</code></pre>
<pre id='var-hash763913' class='code-output documenter-example-output'>599.9999999999998</pre>

<pre class='language-julia'><code class='language-julia'># Let us plot this as in the textbook
begin
using StatsPlots
plot(xlims=(0, 2500), xlabel = "Demand", ylabel = "Probability")
plot!(Normal(1000, 600), marker = :dot, label="Normal(Normal(1000, 600))")
plot!(flextrola_demand, marker = :hex, label="LogNormal{Float64}(μ=6.86, σ=0.307)")
end</code></pre>
<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="600" height="400" viewBox="0 0 2400 1600">
<defs>
  <clipPath id="clip910">
    <rect x="0" y="0" width="2400" height="1600"/>
  </clipPath>
</defs>
<path clip-path="url(#clip910)" d="
M0 1600 L2400 1600 L2400 0 L0 0  Z
  " fill="#ffffff" fill-rule="evenodd" fill-opacity="1"/>
<defs>
  <clipPath id="clip911">
    <rect x="480" y="0" width="1681" height="1600"/>
  </clipPath>
</defs>
<path clip-path="url(#clip910)" d="
M340.028 1423.18 L2352.76 1423.18 L2352.76 47.2441 L340.028 47.2441  Z
  " fill="#ffffff" fill-rule="evenodd" fill-opacity="1"/>
<defs>
  <clipPath id="clip912">
    <rect x="340" y="47" width="2014" height="1377"/>
  </clipPath>
</defs>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  340.028,1423.18 340.028,47.2441 
  "/>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  742.573,1423.18 742.573,47.2441 
  "/>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  1145.12,1423.18 1145.12,47.2441 
  "/>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  1547.66,1423.18 1547.66,47.2441 
  "/>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  1950.21,1423.18 1950.21,47.2441 
  "/>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  2352.76,1423.18 2352.76,47.2441 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  340.028,1423.18 2352.76,1423.18 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  340.028,1423.18 340.028,1404.28 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  742.573,1423.18 742.573,1404.28 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  1145.12,1423.18 1145.12,1404.28 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  1547.66,1423.18 1547.66,1404.28 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  1950.21,1423.18 1950.21,1404.28 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  2352.76,1423.18 2352.76,1404.28 
  "/>
<path clip-path="url(#clip910)" d="M340.028 1454.1 Q336.417 1454.1 334.588 1457.66 Q332.782 1461.2 332.782 1468.33 Q332.782 1475.44 334.588 1479.01 Q336.417 1482.55 340.028 1482.55 Q343.662 1482.55 345.467 1479.01 Q347.296 1475.44 347.296 1468.33 Q347.296 1461.2 345.467 1457.66 Q343.662 1454.1 340.028 1454.1 M340.028 1450.39 Q345.838 1450.39 348.893 1455 Q351.972 1459.58 351.972 1468.33 Q351.972 1477.06 348.893 1481.67 Q345.838 1486.25 340.028 1486.25 Q334.218 1486.25 331.139 1481.67 Q328.083 1477.06 328.083 1468.33 Q328.083 1459.58 331.139 1455 Q334.218 1450.39 340.028 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M702.192 1451.02 L720.548 1451.02 L720.548 1454.96 L706.474 1454.96 L706.474 1463.43 Q707.492 1463.08 708.511 1462.92 Q709.53 1462.73 710.548 1462.73 Q716.335 1462.73 719.715 1465.9 Q723.094 1469.08 723.094 1474.49 Q723.094 1480.07 719.622 1483.17 Q716.15 1486.25 709.83 1486.25 Q707.655 1486.25 705.386 1485.88 Q703.141 1485.51 700.733 1484.77 L700.733 1480.07 Q702.817 1481.2 705.039 1481.76 Q707.261 1482.32 709.738 1482.32 Q713.742 1482.32 716.08 1480.21 Q718.418 1478.1 718.418 1474.49 Q718.418 1470.88 716.08 1468.77 Q713.742 1466.67 709.738 1466.67 Q707.863 1466.67 705.988 1467.08 Q704.136 1467.5 702.192 1468.38 L702.192 1451.02 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M742.307 1454.1 Q738.696 1454.1 736.867 1457.66 Q735.062 1461.2 735.062 1468.33 Q735.062 1475.44 736.867 1479.01 Q738.696 1482.55 742.307 1482.55 Q745.941 1482.55 747.747 1479.01 Q749.576 1475.44 749.576 1468.33 Q749.576 1461.2 747.747 1457.66 Q745.941 1454.1 742.307 1454.1 M742.307 1450.39 Q748.117 1450.39 751.173 1455 Q754.251 1459.58 754.251 1468.33 Q754.251 1477.06 751.173 1481.67 Q748.117 1486.25 742.307 1486.25 Q736.497 1486.25 733.418 1481.67 Q730.363 1477.06 730.363 1468.33 Q730.363 1459.58 733.418 1455 Q736.497 1450.39 742.307 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M772.469 1454.1 Q768.858 1454.1 767.029 1457.66 Q765.224 1461.2 765.224 1468.33 Q765.224 1475.44 767.029 1479.01 Q768.858 1482.55 772.469 1482.55 Q776.103 1482.55 777.909 1479.01 Q779.737 1475.44 779.737 1468.33 Q779.737 1461.2 777.909 1457.66 Q776.103 1454.1 772.469 1454.1 M772.469 1450.39 Q778.279 1450.39 781.335 1455 Q784.413 1459.58 784.413 1468.33 Q784.413 1477.06 781.335 1481.67 Q778.279 1486.25 772.469 1486.25 Q766.659 1486.25 763.58 1481.67 Q760.525 1477.06 760.525 1468.33 Q760.525 1459.58 763.58 1455 Q766.659 1450.39 772.469 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1089.64 1481.64 L1097.28 1481.64 L1097.28 1455.28 L1088.97 1456.95 L1088.97 1452.69 L1097.24 1451.02 L1101.91 1451.02 L1101.91 1481.64 L1109.55 1481.64 L1109.55 1485.58 L1089.64 1485.58 L1089.64 1481.64 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1129 1454.1 Q1125.39 1454.1 1123.56 1457.66 Q1121.75 1461.2 1121.75 1468.33 Q1121.75 1475.44 1123.56 1479.01 Q1125.39 1482.55 1129 1482.55 Q1132.63 1482.55 1134.44 1479.01 Q1136.26 1475.44 1136.26 1468.33 Q1136.26 1461.2 1134.44 1457.66 Q1132.63 1454.1 1129 1454.1 M1129 1450.39 Q1134.81 1450.39 1137.86 1455 Q1140.94 1459.58 1140.94 1468.33 Q1140.94 1477.06 1137.86 1481.67 Q1134.81 1486.25 1129 1486.25 Q1123.19 1486.25 1120.11 1481.67 Q1117.05 1477.06 1117.05 1468.33 Q1117.05 1459.58 1120.11 1455 Q1123.19 1450.39 1129 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1159.16 1454.1 Q1155.55 1454.1 1153.72 1457.66 Q1151.91 1461.2 1151.91 1468.33 Q1151.91 1475.44 1153.72 1479.01 Q1155.55 1482.55 1159.16 1482.55 Q1162.79 1482.55 1164.6 1479.01 Q1166.43 1475.44 1166.43 1468.33 Q1166.43 1461.2 1164.6 1457.66 Q1162.79 1454.1 1159.16 1454.1 M1159.16 1450.39 Q1164.97 1450.39 1168.02 1455 Q1171.1 1459.58 1171.1 1468.33 Q1171.1 1477.06 1168.02 1481.67 Q1164.97 1486.25 1159.16 1486.25 Q1153.35 1486.25 1150.27 1481.67 Q1147.21 1477.06 1147.21 1468.33 Q1147.21 1459.58 1150.27 1455 Q1153.35 1450.39 1159.16 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1189.32 1454.1 Q1185.71 1454.1 1183.88 1457.66 Q1182.07 1461.2 1182.07 1468.33 Q1182.07 1475.44 1183.88 1479.01 Q1185.71 1482.55 1189.32 1482.55 Q1192.95 1482.55 1194.76 1479.01 Q1196.59 1475.44 1196.59 1468.33 Q1196.59 1461.2 1194.76 1457.66 Q1192.95 1454.1 1189.32 1454.1 M1189.32 1450.39 Q1195.13 1450.39 1198.19 1455 Q1201.26 1459.58 1201.26 1468.33 Q1201.26 1477.06 1198.19 1481.67 Q1195.13 1486.25 1189.32 1486.25 Q1183.51 1486.25 1180.43 1481.67 Q1177.38 1477.06 1177.38 1468.33 Q1177.38 1459.58 1180.43 1455 Q1183.51 1450.39 1189.32 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1492.19 1481.64 L1499.83 1481.64 L1499.83 1455.28 L1491.52 1456.95 L1491.52 1452.69 L1499.78 1451.02 L1504.46 1451.02 L1504.46 1481.64 L1512.1 1481.64 L1512.1 1485.58 L1492.19 1485.58 L1492.19 1481.64 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1521.59 1451.02 L1539.94 1451.02 L1539.94 1454.96 L1525.87 1454.96 L1525.87 1463.43 Q1526.89 1463.08 1527.91 1462.92 Q1528.93 1462.73 1529.94 1462.73 Q1535.73 1462.73 1539.11 1465.9 Q1542.49 1469.08 1542.49 1474.49 Q1542.49 1480.07 1539.02 1483.17 Q1535.55 1486.25 1529.23 1486.25 Q1527.05 1486.25 1524.78 1485.88 Q1522.54 1485.51 1520.13 1484.77 L1520.13 1480.07 Q1522.21 1481.2 1524.44 1481.76 Q1526.66 1482.32 1529.13 1482.32 Q1533.14 1482.32 1535.48 1480.21 Q1537.82 1478.1 1537.82 1474.49 Q1537.82 1470.88 1535.48 1468.77 Q1533.14 1466.67 1529.13 1466.67 Q1527.26 1466.67 1525.38 1467.08 Q1523.53 1467.5 1521.59 1468.38 L1521.59 1451.02 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1561.7 1454.1 Q1558.09 1454.1 1556.26 1457.66 Q1554.46 1461.2 1554.46 1468.33 Q1554.46 1475.44 1556.26 1479.01 Q1558.09 1482.55 1561.7 1482.55 Q1565.34 1482.55 1567.14 1479.01 Q1568.97 1475.44 1568.97 1468.33 Q1568.97 1461.2 1567.14 1457.66 Q1565.34 1454.1 1561.7 1454.1 M1561.7 1450.39 Q1567.51 1450.39 1570.57 1455 Q1573.65 1459.58 1573.65 1468.33 Q1573.65 1477.06 1570.57 1481.67 Q1567.51 1486.25 1561.7 1486.25 Q1555.89 1486.25 1552.82 1481.67 Q1549.76 1477.06 1549.76 1468.33 Q1549.76 1459.58 1552.82 1455 Q1555.89 1450.39 1561.7 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1591.87 1454.1 Q1588.25 1454.1 1586.43 1457.66 Q1584.62 1461.2 1584.62 1468.33 Q1584.62 1475.44 1586.43 1479.01 Q1588.25 1482.55 1591.87 1482.55 Q1595.5 1482.55 1597.31 1479.01 Q1599.13 1475.44 1599.13 1468.33 Q1599.13 1461.2 1597.31 1457.66 Q1595.5 1454.1 1591.87 1454.1 M1591.87 1450.39 Q1597.68 1450.39 1600.73 1455 Q1603.81 1459.58 1603.81 1468.33 Q1603.81 1477.06 1600.73 1481.67 Q1597.68 1486.25 1591.87 1486.25 Q1586.06 1486.25 1582.98 1481.67 Q1579.92 1477.06 1579.92 1468.33 Q1579.92 1459.58 1582.98 1455 Q1586.06 1450.39 1591.87 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1898.82 1481.64 L1915.14 1481.64 L1915.14 1485.58 L1893.2 1485.58 L1893.2 1481.64 Q1895.86 1478.89 1900.44 1474.26 Q1905.05 1469.61 1906.23 1468.27 Q1908.47 1465.74 1909.35 1464.01 Q1910.26 1462.25 1910.26 1460.56 Q1910.26 1457.8 1908.31 1456.07 Q1906.39 1454.33 1903.29 1454.33 Q1901.09 1454.33 1898.64 1455.09 Q1896.21 1455.86 1893.43 1457.41 L1893.43 1452.69 Q1896.25 1451.55 1898.71 1450.97 Q1901.16 1450.39 1903.2 1450.39 Q1908.57 1450.39 1911.76 1453.08 Q1914.96 1455.77 1914.96 1460.26 Q1914.96 1462.39 1914.15 1464.31 Q1913.36 1466.2 1911.25 1468.8 Q1910.67 1469.47 1907.57 1472.69 Q1904.47 1475.88 1898.82 1481.64 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1934.96 1454.1 Q1931.34 1454.1 1929.52 1457.66 Q1927.71 1461.2 1927.71 1468.33 Q1927.71 1475.44 1929.52 1479.01 Q1931.34 1482.55 1934.96 1482.55 Q1938.59 1482.55 1940.4 1479.01 Q1942.22 1475.44 1942.22 1468.33 Q1942.22 1461.2 1940.4 1457.66 Q1938.59 1454.1 1934.96 1454.1 M1934.96 1450.39 Q1940.77 1450.39 1943.82 1455 Q1946.9 1459.58 1946.9 1468.33 Q1946.9 1477.06 1943.82 1481.67 Q1940.77 1486.25 1934.96 1486.25 Q1929.15 1486.25 1926.07 1481.67 Q1923.01 1477.06 1923.01 1468.33 Q1923.01 1459.58 1926.07 1455 Q1929.15 1450.39 1934.96 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1965.12 1454.1 Q1961.51 1454.1 1959.68 1457.66 Q1957.87 1461.2 1957.87 1468.33 Q1957.87 1475.44 1959.68 1479.01 Q1961.51 1482.55 1965.12 1482.55 Q1968.75 1482.55 1970.56 1479.01 Q1972.39 1475.44 1972.39 1468.33 Q1972.39 1461.2 1970.56 1457.66 Q1968.75 1454.1 1965.12 1454.1 M1965.12 1450.39 Q1970.93 1450.39 1973.98 1455 Q1977.06 1459.58 1977.06 1468.33 Q1977.06 1477.06 1973.98 1481.67 Q1970.93 1486.25 1965.12 1486.25 Q1959.31 1486.25 1956.23 1481.67 Q1953.17 1477.06 1953.17 1468.33 Q1953.17 1459.58 1956.23 1455 Q1959.31 1450.39 1965.12 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1995.28 1454.1 Q1991.67 1454.1 1989.84 1457.66 Q1988.03 1461.2 1988.03 1468.33 Q1988.03 1475.44 1989.84 1479.01 Q1991.67 1482.55 1995.28 1482.55 Q1998.91 1482.55 2000.72 1479.01 Q2002.55 1475.44 2002.55 1468.33 Q2002.55 1461.2 2000.72 1457.66 Q1998.91 1454.1 1995.28 1454.1 M1995.28 1450.39 Q2001.09 1450.39 2004.15 1455 Q2007.22 1459.58 2007.22 1468.33 Q2007.22 1477.06 2004.15 1481.67 Q2001.09 1486.25 1995.28 1486.25 Q1989.47 1486.25 1986.39 1481.67 Q1983.34 1477.06 1983.34 1468.33 Q1983.34 1459.58 1986.39 1455 Q1989.47 1450.39 1995.28 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2301.37 1481.64 L2317.69 1481.64 L2317.69 1485.58 L2295.74 1485.58 L2295.74 1481.64 Q2298.4 1478.89 2302.99 1474.26 Q2307.59 1469.61 2308.77 1468.27 Q2311.02 1465.74 2311.9 1464.01 Q2312.8 1462.25 2312.8 1460.56 Q2312.8 1457.8 2310.86 1456.07 Q2308.94 1454.33 2305.83 1454.33 Q2303.64 1454.33 2301.18 1455.09 Q2298.75 1455.86 2295.97 1457.41 L2295.97 1452.69 Q2298.8 1451.55 2301.25 1450.97 Q2303.71 1450.39 2305.74 1450.39 Q2311.11 1450.39 2314.31 1453.08 Q2317.5 1455.77 2317.5 1460.26 Q2317.5 1462.39 2316.69 1464.31 Q2315.9 1466.2 2313.8 1468.8 Q2313.22 1469.47 2310.12 1472.69 Q2307.02 1475.88 2301.37 1481.64 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2327.55 1451.02 L2345.9 1451.02 L2345.9 1454.96 L2331.83 1454.96 L2331.83 1463.43 Q2332.85 1463.08 2333.87 1462.92 Q2334.89 1462.73 2335.9 1462.73 Q2341.69 1462.73 2345.07 1465.9 Q2348.45 1469.08 2348.45 1474.49 Q2348.45 1480.07 2344.98 1483.17 Q2341.51 1486.25 2335.19 1486.25 Q2333.01 1486.25 2330.74 1485.88 Q2328.5 1485.51 2326.09 1484.77 L2326.09 1480.07 Q2328.17 1481.2 2330.39 1481.76 Q2332.62 1482.32 2335.09 1482.32 Q2339.1 1482.32 2341.44 1480.21 Q2343.77 1478.1 2343.77 1474.49 Q2343.77 1470.88 2341.44 1468.77 Q2339.1 1466.67 2335.09 1466.67 Q2333.22 1466.67 2331.34 1467.08 Q2329.49 1467.5 2327.55 1468.38 L2327.55 1451.02 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2367.66 1454.1 Q2364.05 1454.1 2362.22 1457.66 Q2360.42 1461.2 2360.42 1468.33 Q2360.42 1475.44 2362.22 1479.01 Q2364.05 1482.55 2367.66 1482.55 Q2371.3 1482.55 2373.1 1479.01 Q2374.93 1475.44 2374.93 1468.33 Q2374.93 1461.2 2373.1 1457.66 Q2371.3 1454.1 2367.66 1454.1 M2367.66 1450.39 Q2373.47 1450.39 2376.53 1455 Q2379.61 1459.58 2379.61 1468.33 Q2379.61 1477.06 2376.53 1481.67 Q2373.47 1486.25 2367.66 1486.25 Q2361.85 1486.25 2358.77 1481.67 Q2355.72 1477.06 2355.72 1468.33 Q2355.72 1459.58 2358.77 1455 Q2361.85 1450.39 2367.66 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2397.83 1454.1 Q2394.21 1454.1 2392.39 1457.66 Q2390.58 1461.2 2390.58 1468.33 Q2390.58 1475.44 2392.39 1479.01 Q2394.21 1482.55 2397.83 1482.55 Q2401.46 1482.55 2403.26 1479.01 Q2405.09 1475.44 2405.09 1468.33 Q2405.09 1461.2 2403.26 1457.66 Q2401.46 1454.1 2397.83 1454.1 M2397.83 1450.39 Q2403.64 1450.39 2406.69 1455 Q2409.77 1459.58 2409.77 1468.33 Q2409.77 1477.06 2406.69 1481.67 Q2403.64 1486.25 2397.83 1486.25 Q2392.01 1486.25 2388.94 1481.67 Q2385.88 1477.06 2385.88 1468.33 Q2385.88 1459.58 2388.94 1455 Q2392.01 1450.39 2397.83 1450.39 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1220.76 1525.81 L1220.76 1562.76 L1228.53 1562.76 Q1238.37 1562.76 1242.92 1558.3 Q1247.5 1553.85 1247.5 1544.24 Q1247.5 1534.69 1242.92 1530.26 Q1238.37 1525.81 1228.53 1525.81 L1220.76 1525.81 M1214.34 1520.52 L1227.54 1520.52 Q1241.36 1520.52 1247.82 1526.28 Q1254.28 1532.01 1254.28 1544.24 Q1254.28 1556.52 1247.79 1562.28 Q1241.29 1568.04 1227.54 1568.04 L1214.34 1568.04 L1214.34 1520.52 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1294.77 1548.76 L1294.77 1551.62 L1267.84 1551.62 Q1268.22 1557.67 1271.47 1560.85 Q1274.75 1564 1280.57 1564 Q1283.94 1564 1287.1 1563.17 Q1290.28 1562.35 1293.4 1560.69 L1293.4 1566.23 Q1290.25 1567.57 1286.94 1568.27 Q1283.63 1568.97 1280.22 1568.97 Q1271.69 1568.97 1266.69 1564 Q1261.73 1559.04 1261.73 1550.57 Q1261.73 1541.82 1266.44 1536.69 Q1271.18 1531.54 1279.2 1531.54 Q1286.39 1531.54 1290.56 1536.18 Q1294.77 1540.8 1294.77 1548.76 M1288.91 1547.04 Q1288.85 1542.23 1286.2 1539.37 Q1283.59 1536.5 1279.27 1536.5 Q1274.36 1536.5 1271.4 1539.27 Q1268.48 1542.04 1268.03 1547.07 L1288.91 1547.04 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1332.13 1539.24 Q1334.33 1535.29 1337.38 1533.41 Q1340.44 1531.54 1344.58 1531.54 Q1350.15 1531.54 1353.17 1535.45 Q1356.19 1539.33 1356.19 1546.53 L1356.19 1568.04 L1350.31 1568.04 L1350.31 1546.72 Q1350.31 1541.59 1348.49 1539.11 Q1346.68 1536.63 1342.95 1536.63 Q1338.4 1536.63 1335.76 1539.65 Q1333.12 1542.68 1333.12 1547.9 L1333.12 1568.04 L1327.23 1568.04 L1327.23 1546.72 Q1327.23 1541.56 1325.42 1539.11 Q1323.6 1536.63 1319.81 1536.63 Q1315.33 1536.63 1312.69 1539.68 Q1310.04 1542.71 1310.04 1547.9 L1310.04 1568.04 L1304.16 1568.04 L1304.16 1532.4 L1310.04 1532.4 L1310.04 1537.93 Q1312.05 1534.66 1314.85 1533.1 Q1317.65 1531.54 1321.5 1531.54 Q1325.38 1531.54 1328.09 1533.51 Q1330.83 1535.48 1332.13 1539.24 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1384.08 1550.12 Q1376.98 1550.12 1374.24 1551.75 Q1371.5 1553.37 1371.5 1557.29 Q1371.5 1560.4 1373.54 1562.25 Q1375.61 1564.07 1379.14 1564.07 Q1384.01 1564.07 1386.94 1560.63 Q1389.9 1557.16 1389.9 1551.43 L1389.9 1550.12 L1384.08 1550.12 M1395.76 1547.71 L1395.76 1568.04 L1389.9 1568.04 L1389.9 1562.63 Q1387.9 1565.88 1384.9 1567.44 Q1381.91 1568.97 1377.58 1568.97 Q1372.11 1568.97 1368.86 1565.91 Q1365.65 1562.82 1365.65 1557.67 Q1365.65 1551.65 1369.66 1548.6 Q1373.7 1545.54 1381.69 1545.54 L1389.9 1545.54 L1389.9 1544.97 Q1389.9 1540.93 1387.23 1538.73 Q1384.59 1536.5 1379.78 1536.5 Q1376.72 1536.5 1373.83 1537.23 Q1370.93 1537.97 1368.26 1539.43 L1368.26 1534.02 Q1371.47 1532.78 1374.5 1532.17 Q1377.52 1531.54 1380.38 1531.54 Q1388.12 1531.54 1391.94 1535.55 Q1395.76 1539.56 1395.76 1547.71 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1437.45 1546.53 L1437.45 1568.04 L1431.6 1568.04 L1431.6 1546.72 Q1431.6 1541.66 1429.62 1539.14 Q1427.65 1536.63 1423.7 1536.63 Q1418.96 1536.63 1416.22 1539.65 Q1413.49 1542.68 1413.49 1547.9 L1413.49 1568.04 L1407.6 1568.04 L1407.6 1532.4 L1413.49 1532.4 L1413.49 1537.93 Q1415.59 1534.72 1418.42 1533.13 Q1421.28 1531.54 1425.01 1531.54 Q1431.15 1531.54 1434.3 1535.36 Q1437.45 1539.14 1437.45 1546.53 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1472.59 1537.81 L1472.59 1518.52 L1478.45 1518.52 L1478.45 1568.04 L1472.59 1568.04 L1472.59 1562.7 Q1470.75 1565.88 1467.91 1567.44 Q1465.11 1568.97 1461.17 1568.97 Q1454.7 1568.97 1450.63 1563.81 Q1446.59 1558.65 1446.59 1550.25 Q1446.59 1541.85 1450.63 1536.69 Q1454.7 1531.54 1461.17 1531.54 Q1465.11 1531.54 1467.91 1533.1 Q1470.75 1534.62 1472.59 1537.81 M1452.64 1550.25 Q1452.64 1556.71 1455.28 1560.4 Q1457.95 1564.07 1462.6 1564.07 Q1467.24 1564.07 1469.92 1560.4 Q1472.59 1556.71 1472.59 1550.25 Q1472.59 1543.79 1469.92 1540.13 Q1467.24 1536.44 1462.6 1536.44 Q1457.95 1536.44 1455.28 1540.13 Q1452.64 1543.79 1452.64 1550.25 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  340.028,1384.24 2352.76,1384.24 
  "/>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  340.028,1052.57 2352.76,1052.57 
  "/>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  340.028,720.901 2352.76,720.901 
  "/>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  340.028,389.233 2352.76,389.233 
  "/>
<polyline clip-path="url(#clip912)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:2; stroke-opacity:0.1; fill:none" points="
  340.028,57.5643 2352.76,57.5643 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  340.028,1423.18 340.028,47.2441 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  340.028,1384.24 358.925,1384.24 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  340.028,1052.57 358.925,1052.57 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  340.028,720.901 358.925,720.901 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  340.028,389.233 358.925,389.233 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  340.028,57.5643 358.925,57.5643 
  "/>
<path clip-path="url(#clip910)" d="M126.205 1370.04 Q122.593 1370.04 120.765 1373.6 Q118.959 1377.14 118.959 1384.27 Q118.959 1391.38 120.765 1394.94 Q122.593 1398.49 126.205 1398.49 Q129.839 1398.49 131.644 1394.94 Q133.473 1391.38 133.473 1384.27 Q133.473 1377.14 131.644 1373.6 Q129.839 1370.04 126.205 1370.04 M126.205 1366.33 Q132.015 1366.33 135.07 1370.94 Q138.149 1375.52 138.149 1384.27 Q138.149 1393 135.07 1397.61 Q132.015 1402.19 126.205 1402.19 Q120.394 1402.19 117.316 1397.61 Q114.26 1393 114.26 1384.27 Q114.26 1375.52 117.316 1370.94 Q120.394 1366.33 126.205 1366.33 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M146.366 1395.64 L151.251 1395.64 L151.251 1401.52 L146.366 1401.52 L146.366 1395.64 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M171.436 1370.04 Q167.825 1370.04 165.996 1373.6 Q164.19 1377.14 164.19 1384.27 Q164.19 1391.38 165.996 1394.94 Q167.825 1398.49 171.436 1398.49 Q175.07 1398.49 176.876 1394.94 Q178.704 1391.38 178.704 1384.27 Q178.704 1377.14 176.876 1373.6 Q175.07 1370.04 171.436 1370.04 M171.436 1366.33 Q177.246 1366.33 180.301 1370.94 Q183.38 1375.52 183.38 1384.27 Q183.38 1393 180.301 1397.61 Q177.246 1402.19 171.436 1402.19 Q165.626 1402.19 162.547 1397.61 Q159.491 1393 159.491 1384.27 Q159.491 1375.52 162.547 1370.94 Q165.626 1366.33 171.436 1366.33 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M201.598 1370.04 Q197.987 1370.04 196.158 1373.6 Q194.352 1377.14 194.352 1384.27 Q194.352 1391.38 196.158 1394.94 Q197.987 1398.49 201.598 1398.49 Q205.232 1398.49 207.037 1394.94 Q208.866 1391.38 208.866 1384.27 Q208.866 1377.14 207.037 1373.6 Q205.232 1370.04 201.598 1370.04 M201.598 1366.33 Q207.408 1366.33 210.463 1370.94 Q213.542 1375.52 213.542 1384.27 Q213.542 1393 210.463 1397.61 Q207.408 1402.19 201.598 1402.19 Q195.787 1402.19 192.709 1397.61 Q189.653 1393 189.653 1384.27 Q189.653 1375.52 192.709 1370.94 Q195.787 1366.33 201.598 1366.33 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M231.76 1370.04 Q228.148 1370.04 226.32 1373.6 Q224.514 1377.14 224.514 1384.27 Q224.514 1391.38 226.32 1394.94 Q228.148 1398.49 231.76 1398.49 Q235.394 1398.49 237.199 1394.94 Q239.028 1391.38 239.028 1384.27 Q239.028 1377.14 237.199 1373.6 Q235.394 1370.04 231.76 1370.04 M231.76 1366.33 Q237.57 1366.33 240.625 1370.94 Q243.704 1375.52 243.704 1384.27 Q243.704 1393 240.625 1397.61 Q237.57 1402.19 231.76 1402.19 Q225.949 1402.19 222.871 1397.61 Q219.815 1393 219.815 1384.27 Q219.815 1375.52 222.871 1370.94 Q225.949 1366.33 231.76 1366.33 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M261.921 1370.04 Q258.31 1370.04 256.482 1373.6 Q254.676 1377.14 254.676 1384.27 Q254.676 1391.38 256.482 1394.94 Q258.31 1398.49 261.921 1398.49 Q265.556 1398.49 267.361 1394.94 Q269.19 1391.38 269.19 1384.27 Q269.19 1377.14 267.361 1373.6 Q265.556 1370.04 261.921 1370.04 M261.921 1366.33 Q267.732 1366.33 270.787 1370.94 Q273.866 1375.52 273.866 1384.27 Q273.866 1393 270.787 1397.61 Q267.732 1402.19 261.921 1402.19 Q256.111 1402.19 253.033 1397.61 Q249.977 1393 249.977 1384.27 Q249.977 1375.52 253.033 1370.94 Q256.111 1366.33 261.921 1366.33 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M292.083 1370.04 Q288.472 1370.04 286.643 1373.6 Q284.838 1377.14 284.838 1384.27 Q284.838 1391.38 286.643 1394.94 Q288.472 1398.49 292.083 1398.49 Q295.718 1398.49 297.523 1394.94 Q299.352 1391.38 299.352 1384.27 Q299.352 1377.14 297.523 1373.6 Q295.718 1370.04 292.083 1370.04 M292.083 1366.33 Q297.893 1366.33 300.949 1370.94 Q304.028 1375.52 304.028 1384.27 Q304.028 1393 300.949 1397.61 Q297.893 1402.19 292.083 1402.19 Q286.273 1402.19 283.194 1397.61 Q280.139 1393 280.139 1384.27 Q280.139 1375.52 283.194 1370.94 Q286.273 1366.33 292.083 1366.33 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M127.2 1038.37 Q123.589 1038.37 121.76 1041.93 Q119.955 1045.47 119.955 1052.6 Q119.955 1059.71 121.76 1063.28 Q123.589 1066.82 127.2 1066.82 Q130.834 1066.82 132.64 1063.28 Q134.468 1059.71 134.468 1052.6 Q134.468 1045.47 132.64 1041.93 Q130.834 1038.37 127.2 1038.37 M127.2 1034.66 Q133.01 1034.66 136.066 1039.27 Q139.144 1043.85 139.144 1052.6 Q139.144 1061.33 136.066 1065.94 Q133.01 1070.52 127.2 1070.52 Q121.39 1070.52 118.311 1065.94 Q115.256 1061.33 115.256 1052.6 Q115.256 1043.85 118.311 1039.27 Q121.39 1034.66 127.2 1034.66 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M147.362 1063.97 L152.246 1063.97 L152.246 1069.85 L147.362 1069.85 L147.362 1063.97 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M172.431 1038.37 Q168.82 1038.37 166.991 1041.93 Q165.186 1045.47 165.186 1052.6 Q165.186 1059.71 166.991 1063.28 Q168.82 1066.82 172.431 1066.82 Q176.065 1066.82 177.871 1063.28 Q179.7 1059.71 179.7 1052.6 Q179.7 1045.47 177.871 1041.93 Q176.065 1038.37 172.431 1038.37 M172.431 1034.66 Q178.241 1034.66 181.297 1039.27 Q184.376 1043.85 184.376 1052.6 Q184.376 1061.33 181.297 1065.94 Q178.241 1070.52 172.431 1070.52 Q166.621 1070.52 163.542 1065.94 Q160.487 1061.33 160.487 1052.6 Q160.487 1043.85 163.542 1039.27 Q166.621 1034.66 172.431 1034.66 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M202.593 1038.37 Q198.982 1038.37 197.153 1041.93 Q195.348 1045.47 195.348 1052.6 Q195.348 1059.71 197.153 1063.28 Q198.982 1066.82 202.593 1066.82 Q206.227 1066.82 208.033 1063.28 Q209.861 1059.71 209.861 1052.6 Q209.861 1045.47 208.033 1041.93 Q206.227 1038.37 202.593 1038.37 M202.593 1034.66 Q208.403 1034.66 211.459 1039.27 Q214.537 1043.85 214.537 1052.6 Q214.537 1061.33 211.459 1065.94 Q208.403 1070.52 202.593 1070.52 Q196.783 1070.52 193.704 1065.94 Q190.649 1061.33 190.649 1052.6 Q190.649 1043.85 193.704 1039.27 Q196.783 1034.66 202.593 1034.66 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M232.755 1038.37 Q229.144 1038.37 227.315 1041.93 Q225.51 1045.47 225.51 1052.6 Q225.51 1059.71 227.315 1063.28 Q229.144 1066.82 232.755 1066.82 Q236.389 1066.82 238.195 1063.28 Q240.023 1059.71 240.023 1052.6 Q240.023 1045.47 238.195 1041.93 Q236.389 1038.37 232.755 1038.37 M232.755 1034.66 Q238.565 1034.66 241.621 1039.27 Q244.699 1043.85 244.699 1052.6 Q244.699 1061.33 241.621 1065.94 Q238.565 1070.52 232.755 1070.52 Q226.945 1070.52 223.866 1065.94 Q220.811 1061.33 220.811 1052.6 Q220.811 1043.85 223.866 1039.27 Q226.945 1034.66 232.755 1034.66 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M256.945 1065.91 L273.264 1065.91 L273.264 1069.85 L251.32 1069.85 L251.32 1065.91 Q253.982 1063.16 258.565 1058.53 Q263.171 1053.88 264.352 1052.54 Q266.597 1050.01 267.477 1048.28 Q268.38 1046.52 268.38 1044.83 Q268.38 1042.07 266.435 1040.34 Q264.514 1038.6 261.412 1038.6 Q259.213 1038.6 256.759 1039.36 Q254.329 1040.13 251.551 1041.68 L251.551 1036.96 Q254.375 1035.82 256.829 1035.24 Q259.283 1034.66 261.32 1034.66 Q266.69 1034.66 269.884 1037.35 Q273.079 1040.04 273.079 1044.53 Q273.079 1046.66 272.269 1048.58 Q271.482 1050.47 269.375 1053.07 Q268.796 1053.74 265.695 1056.96 Q262.593 1060.15 256.945 1065.91 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M283.125 1035.29 L301.481 1035.29 L301.481 1039.22 L287.407 1039.22 L287.407 1047.7 Q288.426 1047.35 289.444 1047.19 Q290.463 1047 291.481 1047 Q297.268 1047 300.648 1050.17 Q304.028 1053.35 304.028 1058.76 Q304.028 1064.34 300.555 1067.44 Q297.083 1070.52 290.764 1070.52 Q288.588 1070.52 286.319 1070.15 Q284.074 1069.78 281.667 1069.04 L281.667 1064.34 Q283.75 1065.47 285.972 1066.03 Q288.194 1066.59 290.671 1066.59 Q294.676 1066.59 297.014 1064.48 Q299.352 1062.37 299.352 1058.76 Q299.352 1055.15 297.014 1053.04 Q294.676 1050.94 290.671 1050.94 Q288.796 1050.94 286.921 1051.35 Q285.069 1051.77 283.125 1052.65 L283.125 1035.29 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M126.205 706.7 Q122.593 706.7 120.765 710.265 Q118.959 713.806 118.959 720.936 Q118.959 728.042 120.765 731.607 Q122.593 735.149 126.205 735.149 Q129.839 735.149 131.644 731.607 Q133.473 728.042 133.473 720.936 Q133.473 713.806 131.644 710.265 Q129.839 706.7 126.205 706.7 M126.205 702.996 Q132.015 702.996 135.07 707.603 Q138.149 712.186 138.149 720.936 Q138.149 729.663 135.07 734.269 Q132.015 738.853 126.205 738.853 Q120.394 738.853 117.316 734.269 Q114.26 729.663 114.26 720.936 Q114.26 712.186 117.316 707.603 Q120.394 702.996 126.205 702.996 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M146.366 732.302 L151.251 732.302 L151.251 738.181 L146.366 738.181 L146.366 732.302 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M171.436 706.7 Q167.825 706.7 165.996 710.265 Q164.19 713.806 164.19 720.936 Q164.19 728.042 165.996 731.607 Q167.825 735.149 171.436 735.149 Q175.07 735.149 176.876 731.607 Q178.704 728.042 178.704 720.936 Q178.704 713.806 176.876 710.265 Q175.07 706.7 171.436 706.7 M171.436 702.996 Q177.246 702.996 180.301 707.603 Q183.38 712.186 183.38 720.936 Q183.38 729.663 180.301 734.269 Q177.246 738.853 171.436 738.853 Q165.626 738.853 162.547 734.269 Q159.491 729.663 159.491 720.936 Q159.491 712.186 162.547 707.603 Q165.626 702.996 171.436 702.996 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M201.598 706.7 Q197.987 706.7 196.158 710.265 Q194.352 713.806 194.352 720.936 Q194.352 728.042 196.158 731.607 Q197.987 735.149 201.598 735.149 Q205.232 735.149 207.037 731.607 Q208.866 728.042 208.866 720.936 Q208.866 713.806 207.037 710.265 Q205.232 706.7 201.598 706.7 M201.598 702.996 Q207.408 702.996 210.463 707.603 Q213.542 712.186 213.542 720.936 Q213.542 729.663 210.463 734.269 Q207.408 738.853 201.598 738.853 Q195.787 738.853 192.709 734.269 Q189.653 729.663 189.653 720.936 Q189.653 712.186 192.709 707.603 Q195.787 702.996 201.598 702.996 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M231.76 706.7 Q228.148 706.7 226.32 710.265 Q224.514 713.806 224.514 720.936 Q224.514 728.042 226.32 731.607 Q228.148 735.149 231.76 735.149 Q235.394 735.149 237.199 731.607 Q239.028 728.042 239.028 720.936 Q239.028 713.806 237.199 710.265 Q235.394 706.7 231.76 706.7 M231.76 702.996 Q237.57 702.996 240.625 707.603 Q243.704 712.186 243.704 720.936 Q243.704 729.663 240.625 734.269 Q237.57 738.853 231.76 738.853 Q225.949 738.853 222.871 734.269 Q219.815 729.663 219.815 720.936 Q219.815 712.186 222.871 707.603 Q225.949 702.996 231.76 702.996 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M251.968 703.621 L270.324 703.621 L270.324 707.556 L256.25 707.556 L256.25 716.029 Q257.269 715.681 258.287 715.519 Q259.306 715.334 260.324 715.334 Q266.111 715.334 269.491 718.505 Q272.87 721.677 272.87 727.093 Q272.87 732.672 269.398 735.774 Q265.926 738.853 259.607 738.853 Q257.431 738.853 255.162 738.482 Q252.917 738.112 250.509 737.371 L250.509 732.672 Q252.593 733.806 254.815 734.362 Q257.037 734.917 259.514 734.917 Q263.519 734.917 265.857 732.811 Q268.195 730.704 268.195 727.093 Q268.195 723.482 265.857 721.376 Q263.519 719.269 259.514 719.269 Q257.639 719.269 255.764 719.686 Q253.912 720.103 251.968 720.982 L251.968 703.621 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M292.083 706.7 Q288.472 706.7 286.643 710.265 Q284.838 713.806 284.838 720.936 Q284.838 728.042 286.643 731.607 Q288.472 735.149 292.083 735.149 Q295.718 735.149 297.523 731.607 Q299.352 728.042 299.352 720.936 Q299.352 713.806 297.523 710.265 Q295.718 706.7 292.083 706.7 M292.083 702.996 Q297.893 702.996 300.949 707.603 Q304.028 712.186 304.028 720.936 Q304.028 729.663 300.949 734.269 Q297.893 738.853 292.083 738.853 Q286.273 738.853 283.194 734.269 Q280.139 729.663 280.139 720.936 Q280.139 712.186 283.194 707.603 Q286.273 702.996 292.083 702.996 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M127.2 375.031 Q123.589 375.031 121.76 378.596 Q119.955 382.138 119.955 389.268 Q119.955 396.374 121.76 399.939 Q123.589 403.48 127.2 403.48 Q130.834 403.48 132.64 399.939 Q134.468 396.374 134.468 389.268 Q134.468 382.138 132.64 378.596 Q130.834 375.031 127.2 375.031 M127.2 371.328 Q133.01 371.328 136.066 375.934 Q139.144 380.518 139.144 389.268 Q139.144 397.994 136.066 402.601 Q133.01 407.184 127.2 407.184 Q121.39 407.184 118.311 402.601 Q115.256 397.994 115.256 389.268 Q115.256 380.518 118.311 375.934 Q121.39 371.328 127.2 371.328 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M147.362 400.633 L152.246 400.633 L152.246 406.513 L147.362 406.513 L147.362 400.633 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M172.431 375.031 Q168.82 375.031 166.991 378.596 Q165.186 382.138 165.186 389.268 Q165.186 396.374 166.991 399.939 Q168.82 403.48 172.431 403.48 Q176.065 403.48 177.871 399.939 Q179.7 396.374 179.7 389.268 Q179.7 382.138 177.871 378.596 Q176.065 375.031 172.431 375.031 M172.431 371.328 Q178.241 371.328 181.297 375.934 Q184.376 380.518 184.376 389.268 Q184.376 397.994 181.297 402.601 Q178.241 407.184 172.431 407.184 Q166.621 407.184 163.542 402.601 Q160.487 397.994 160.487 389.268 Q160.487 380.518 163.542 375.934 Q166.621 371.328 172.431 371.328 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M202.593 375.031 Q198.982 375.031 197.153 378.596 Q195.348 382.138 195.348 389.268 Q195.348 396.374 197.153 399.939 Q198.982 403.48 202.593 403.48 Q206.227 403.48 208.033 399.939 Q209.861 396.374 209.861 389.268 Q209.861 382.138 208.033 378.596 Q206.227 375.031 202.593 375.031 M202.593 371.328 Q208.403 371.328 211.459 375.934 Q214.537 380.518 214.537 389.268 Q214.537 397.994 211.459 402.601 Q208.403 407.184 202.593 407.184 Q196.783 407.184 193.704 402.601 Q190.649 397.994 190.649 389.268 Q190.649 380.518 193.704 375.934 Q196.783 371.328 202.593 371.328 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M232.755 375.031 Q229.144 375.031 227.315 378.596 Q225.51 382.138 225.51 389.268 Q225.51 396.374 227.315 399.939 Q229.144 403.48 232.755 403.48 Q236.389 403.48 238.195 399.939 Q240.023 396.374 240.023 389.268 Q240.023 382.138 238.195 378.596 Q236.389 375.031 232.755 375.031 M232.755 371.328 Q238.565 371.328 241.621 375.934 Q244.699 380.518 244.699 389.268 Q244.699 397.994 241.621 402.601 Q238.565 407.184 232.755 407.184 Q226.945 407.184 223.866 402.601 Q220.811 397.994 220.811 389.268 Q220.811 380.518 223.866 375.934 Q226.945 371.328 232.755 371.328 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M251.736 371.953 L273.958 371.953 L273.958 373.944 L261.412 406.513 L256.528 406.513 L268.333 375.888 L251.736 375.888 L251.736 371.953 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M283.125 371.953 L301.481 371.953 L301.481 375.888 L287.407 375.888 L287.407 384.36 Q288.426 384.013 289.444 383.851 Q290.463 383.666 291.481 383.666 Q297.268 383.666 300.648 386.837 Q304.028 390.008 304.028 395.425 Q304.028 401.004 300.555 404.105 Q297.083 407.184 290.764 407.184 Q288.588 407.184 286.319 406.814 Q284.074 406.443 281.667 405.703 L281.667 401.004 Q283.75 402.138 285.972 402.693 Q288.194 403.249 290.671 403.249 Q294.676 403.249 297.014 401.142 Q299.352 399.036 299.352 395.425 Q299.352 391.814 297.014 389.707 Q294.676 387.601 290.671 387.601 Q288.796 387.601 286.921 388.018 Q285.069 388.434 283.125 389.314 L283.125 371.953 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M126.205 43.363 Q122.593 43.363 120.765 46.9278 Q118.959 50.4695 118.959 57.599 Q118.959 64.7055 120.765 68.2703 Q122.593 71.8119 126.205 71.8119 Q129.839 71.8119 131.644 68.2703 Q133.473 64.7055 133.473 57.599 Q133.473 50.4695 131.644 46.9278 Q129.839 43.363 126.205 43.363 M126.205 39.6593 Q132.015 39.6593 135.07 44.2658 Q138.149 48.8491 138.149 57.599 Q138.149 66.3259 135.07 70.9323 Q132.015 75.5156 126.205 75.5156 Q120.394 75.5156 117.316 70.9323 Q114.26 66.3259 114.26 57.599 Q114.26 48.8491 117.316 44.2658 Q120.394 39.6593 126.205 39.6593 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M146.366 68.9647 L151.251 68.9647 L151.251 74.8443 L146.366 74.8443 L146.366 68.9647 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M171.436 43.363 Q167.825 43.363 165.996 46.9278 Q164.19 50.4695 164.19 57.599 Q164.19 64.7055 165.996 68.2703 Q167.825 71.8119 171.436 71.8119 Q175.07 71.8119 176.876 68.2703 Q178.704 64.7055 178.704 57.599 Q178.704 50.4695 176.876 46.9278 Q175.07 43.363 171.436 43.363 M171.436 39.6593 Q177.246 39.6593 180.301 44.2658 Q183.38 48.8491 183.38 57.599 Q183.38 66.3259 180.301 70.9323 Q177.246 75.5156 171.436 75.5156 Q165.626 75.5156 162.547 70.9323 Q159.491 66.3259 159.491 57.599 Q159.491 48.8491 162.547 44.2658 Q165.626 39.6593 171.436 39.6593 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M201.598 43.363 Q197.987 43.363 196.158 46.9278 Q194.352 50.4695 194.352 57.599 Q194.352 64.7055 196.158 68.2703 Q197.987 71.8119 201.598 71.8119 Q205.232 71.8119 207.037 68.2703 Q208.866 64.7055 208.866 57.599 Q208.866 50.4695 207.037 46.9278 Q205.232 43.363 201.598 43.363 M201.598 39.6593 Q207.408 39.6593 210.463 44.2658 Q213.542 48.8491 213.542 57.599 Q213.542 66.3259 210.463 70.9323 Q207.408 75.5156 201.598 75.5156 Q195.787 75.5156 192.709 70.9323 Q189.653 66.3259 189.653 57.599 Q189.653 48.8491 192.709 44.2658 Q195.787 39.6593 201.598 39.6593 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M222.57 70.9092 L230.209 70.9092 L230.209 44.5436 L221.898 46.2102 L221.898 41.951 L230.162 40.2843 L234.838 40.2843 L234.838 70.9092 L242.477 70.9092 L242.477 74.8443 L222.57 74.8443 L222.57 70.9092 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M261.921 43.363 Q258.31 43.363 256.482 46.9278 Q254.676 50.4695 254.676 57.599 Q254.676 64.7055 256.482 68.2703 Q258.31 71.8119 261.921 71.8119 Q265.556 71.8119 267.361 68.2703 Q269.19 64.7055 269.19 57.599 Q269.19 50.4695 267.361 46.9278 Q265.556 43.363 261.921 43.363 M261.921 39.6593 Q267.732 39.6593 270.787 44.2658 Q273.866 48.8491 273.866 57.599 Q273.866 66.3259 270.787 70.9323 Q267.732 75.5156 261.921 75.5156 Q256.111 75.5156 253.033 70.9323 Q249.977 66.3259 249.977 57.599 Q249.977 48.8491 253.033 44.2658 Q256.111 39.6593 261.921 39.6593 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M292.083 43.363 Q288.472 43.363 286.643 46.9278 Q284.838 50.4695 284.838 57.599 Q284.838 64.7055 286.643 68.2703 Q288.472 71.8119 292.083 71.8119 Q295.718 71.8119 297.523 68.2703 Q299.352 64.7055 299.352 57.599 Q299.352 50.4695 297.523 46.9278 Q295.718 43.363 292.083 43.363 M292.083 39.6593 Q297.893 39.6593 300.949 44.2658 Q304.028 48.8491 304.028 57.599 Q304.028 66.3259 300.949 70.9323 Q297.893 75.5156 292.083 75.5156 Q286.273 75.5156 283.194 70.9323 Q280.139 66.3259 280.139 57.599 Q280.139 48.8491 283.194 44.2658 Q286.273 39.6593 292.083 39.6593 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M21.7677 896.901 L39.6235 896.901 L39.6235 888.816 Q39.6235 884.329 37.3 881.878 Q34.9765 879.427 30.6797 879.427 Q26.4147 879.427 24.0912 881.878 Q21.7677 884.329 21.7677 888.816 L21.7677 896.901 M16.4842 903.33 L16.4842 888.816 Q16.4842 880.828 20.1126 876.753 Q23.7092 872.648 30.6797 872.648 Q37.7138 872.648 41.3104 876.753 Q44.907 880.828 44.907 888.816 L44.907 896.901 L64.0042 896.901 L64.0042 903.33 L16.4842 903.33 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M33.8307 844.766 Q33.2578 845.752 33.0032 846.93 Q32.7167 848.076 32.7167 849.476 Q32.7167 854.442 35.9632 857.115 Q39.1779 859.757 45.2253 859.757 L64.0042 859.757 L64.0042 865.645 L28.3562 865.645 L28.3562 859.757 L33.8944 859.757 Q30.6479 857.911 29.0883 854.951 Q27.4968 851.991 27.4968 847.758 Q27.4968 847.153 27.5923 846.421 Q27.656 845.689 27.8151 844.798 L33.8307 844.766 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M32.4621 826.242 Q32.4621 830.952 36.1542 833.689 Q39.8145 836.427 46.212 836.427 Q52.6095 836.427 56.3017 833.721 Q59.9619 830.984 59.9619 826.242 Q59.9619 821.563 56.2698 818.826 Q52.5777 816.088 46.212 816.088 Q39.8781 816.088 36.186 818.826 Q32.4621 821.563 32.4621 826.242 M27.4968 826.242 Q27.4968 818.603 32.4621 814.242 Q37.4273 809.882 46.212 809.882 Q54.9649 809.882 59.9619 814.242 Q64.9272 818.603 64.9272 826.242 Q64.9272 833.912 59.9619 838.273 Q54.9649 842.601 46.212 842.601 Q37.4273 842.601 32.4621 838.273 Q27.4968 833.912 27.4968 826.242 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M46.212 774.584 Q39.7508 774.584 36.0905 777.257 Q32.3984 779.899 32.3984 784.546 Q32.3984 789.193 36.0905 791.867 Q39.7508 794.509 46.212 794.509 Q52.6732 794.509 56.3653 791.867 Q60.0256 789.193 60.0256 784.546 Q60.0256 779.899 56.3653 777.257 Q52.6732 774.584 46.212 774.584 M33.7671 794.509 Q30.5842 792.662 29.0564 789.862 Q27.4968 787.029 27.4968 783.114 Q27.4968 776.621 32.6531 772.579 Q37.8093 768.505 46.212 768.505 Q54.6147 768.505 59.771 772.579 Q64.9272 776.621 64.9272 783.114 Q64.9272 787.029 63.3994 789.862 Q61.8398 792.662 58.657 794.509 L64.0042 794.509 L64.0042 800.397 L14.479 800.397 L14.479 794.509 L33.7671 794.509 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M46.0847 742.596 Q46.0847 749.694 47.7079 752.431 Q49.3312 755.168 53.2461 755.168 Q56.3653 755.168 58.2114 753.131 Q60.0256 751.063 60.0256 747.53 Q60.0256 742.66 56.5881 739.732 Q53.1188 736.772 47.3897 736.772 L46.0847 736.772 L46.0847 742.596 M43.6657 730.915 L64.0042 730.915 L64.0042 736.772 L58.5933 736.772 Q61.8398 738.777 63.3994 741.769 Q64.9272 744.761 64.9272 749.089 Q64.9272 754.564 61.8716 757.81 Q58.7843 761.025 53.6281 761.025 Q47.6125 761.025 44.5569 757.015 Q41.5014 752.972 41.5014 744.983 L41.5014 736.772 L40.9285 736.772 Q36.8862 736.772 34.6901 739.445 Q32.4621 742.087 32.4621 746.893 Q32.4621 749.949 33.1941 752.845 Q33.9262 755.741 35.3903 758.415 L29.9795 758.415 Q28.7381 755.2 28.1334 752.177 Q27.4968 749.153 27.4968 746.288 Q27.4968 738.554 31.5072 734.735 Q35.5176 730.915 43.6657 730.915 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M46.212 693.262 Q39.7508 693.262 36.0905 695.936 Q32.3984 698.577 32.3984 703.224 Q32.3984 707.871 36.0905 710.545 Q39.7508 713.187 46.212 713.187 Q52.6732 713.187 56.3653 710.545 Q60.0256 707.871 60.0256 703.224 Q60.0256 698.577 56.3653 695.936 Q52.6732 693.262 46.212 693.262 M33.7671 713.187 Q30.5842 711.341 29.0564 708.54 Q27.4968 705.707 27.4968 701.792 Q27.4968 695.299 32.6531 691.257 Q37.8093 687.183 46.212 687.183 Q54.6147 687.183 59.771 691.257 Q64.9272 695.299 64.9272 701.792 Q64.9272 705.707 63.3994 708.54 Q61.8398 711.341 58.657 713.187 L64.0042 713.187 L64.0042 719.075 L14.479 719.075 L14.479 713.187 L33.7671 713.187 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M28.3562 677.475 L28.3562 671.619 L64.0042 671.619 L64.0042 677.475 L28.3562 677.475 M14.479 677.475 L14.479 671.619 L21.895 671.619 L21.895 677.475 L14.479 677.475 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M14.479 659.365 L14.479 653.508 L64.0042 653.508 L64.0042 659.365 L14.479 659.365 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M28.3562 641.254 L28.3562 635.398 L64.0042 635.398 L64.0042 641.254 L28.3562 641.254 M14.479 641.254 L14.479 635.398 L21.895 635.398 L21.895 641.254 L14.479 641.254 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M18.2347 617.351 L28.3562 617.351 L28.3562 605.288 L32.9077 605.288 L32.9077 617.351 L52.2594 617.351 Q56.6199 617.351 57.8613 616.173 Q59.1026 614.964 59.1026 611.303 L59.1026 605.288 L64.0042 605.288 L64.0042 611.303 Q64.0042 618.083 61.4897 620.661 Q58.9434 623.239 52.2594 623.239 L32.9077 623.239 L32.9077 627.536 L28.3562 627.536 L28.3562 623.239 L18.2347 623.239 L18.2347 617.351 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M67.3143 582.753 Q73.68 585.236 75.6216 587.591 Q77.5631 589.947 77.5631 593.893 L77.5631 598.572 L72.6615 598.572 L72.6615 595.135 Q72.6615 592.716 71.5157 591.379 Q70.3699 590.042 66.1048 588.419 L63.4312 587.368 L28.3562 601.787 L28.3562 595.58 L56.238 584.44 L28.3562 573.3 L28.3562 567.094 L67.3143 582.753 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><polyline clip-path="url(#clip912)" style="stroke:#009af9; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  -651.37,1383.36 -639.674,1383.28 -627.977,1383.19 -519.83,1381.92 -411.682,1379.34 -346.69,1376.75 -281.698,1372.99 -226.748,1368.6 -171.798,1362.78 -141.952,1358.89 
  -112.107,1354.41 -82.2613,1349.27 -52.4157,1343.41 -24.9007,1337.29 2.61428,1330.44 30.1293,1322.78 57.6442,1314.25 87.1432,1304.09 116.642,1292.79 146.141,1280.29 
  175.64,1266.51 209.818,1248.89 243.995,1229.41 278.172,1208 312.35,1184.64 342.723,1162.23 373.096,1138.28 403.469,1112.81 433.841,1085.89 460.476,1061.15 
  487.11,1035.42 513.744,1008.79 540.379,981.342 598.456,919.271 656.533,855.338 714.955,790.87 773.377,728.211 789.525,711.491 805.674,695.115 821.822,679.129 
  837.97,663.579 854.119,648.508 870.267,633.96 886.415,619.98 902.563,606.608 917.928,594.488 933.293,582.99 948.658,572.147 964.022,561.99 979.387,552.547 
  994.752,543.846 1010.12,535.913 1025.48,528.771 1041.46,522.207 1057.43,516.542 1073.41,511.794 1089.38,507.98 1105.36,505.111 1121.34,503.196 1137.31,502.243 
  1153.29,502.254 1166.74,503.01 1180.18,504.449 1193.63,506.565 1207.08,509.355 1220.53,512.811 1233.98,516.926 1247.42,521.691 1260.87,527.094 1277.29,534.537 
  1293.71,542.889 1310.13,552.121 1326.55,562.201 1342.97,573.097 1359.38,584.773 1375.8,597.19 1392.22,610.309 1422.3,636.027 1452.38,663.689 1467.42,678.161 
  1482.46,693.014 1497.51,708.21 1512.55,723.712 1568.11,783.038 1623.67,844.228 1679.96,906.355 1736.24,967.038 1767.78,999.895 1799.32,1031.67 1830.86,1062.2 
  1862.4,1091.33 1890.98,1116.43 1919.56,1140.24 1948.14,1162.71 1976.73,1183.81 2009.45,1206.28 2042.17,1226.96 2074.89,1245.87 2107.61,1263.06 2137.91,1277.51 
  2168.21,1290.6 2198.51,1302.41 2228.81,1313.01 2258.68,1322.36 2288.55,1330.68 2318.42,1338.06 2348.29,1344.58 2377.29,1350.15 2406.29,1355.04 2435.29,1359.32 
  2464.29,1363.05 2523.75,1369.21 2583.22,1373.74 2648.36,1377.28 2713.51,1379.71 2808.14,1381.88 2902.78,1383.06 2922.19,1383.22 2941.61,1383.36 
  "/>
<circle clip-path="url(#clip912)" cx="342.723" cy="1162.23" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="373.096" cy="1138.28" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="403.469" cy="1112.81" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="433.841" cy="1085.89" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="460.476" cy="1061.15" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="487.11" cy="1035.42" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="513.744" cy="1008.79" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="540.379" cy="981.342" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="598.456" cy="919.271" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="656.533" cy="855.338" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="714.955" cy="790.87" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="773.377" cy="728.211" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="789.525" cy="711.491" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="805.674" cy="695.115" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="821.822" cy="679.129" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="837.97" cy="663.579" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="854.119" cy="648.508" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="870.267" cy="633.96" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="886.415" cy="619.98" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="902.563" cy="606.608" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="917.928" cy="594.488" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="933.293" cy="582.99" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="948.658" cy="572.147" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="964.022" cy="561.99" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="979.387" cy="552.547" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="994.752" cy="543.846" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1010.12" cy="535.913" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1025.48" cy="528.771" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1041.46" cy="522.207" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1057.43" cy="516.542" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1073.41" cy="511.794" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1089.38" cy="507.98" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1105.36" cy="505.111" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1121.34" cy="503.196" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1137.31" cy="502.243" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1153.29" cy="502.254" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1166.74" cy="503.01" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1180.18" cy="504.449" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1193.63" cy="506.565" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1207.08" cy="509.355" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1220.53" cy="512.811" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1233.98" cy="516.926" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1247.42" cy="521.691" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1260.87" cy="527.094" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1277.29" cy="534.537" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1293.71" cy="542.889" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1310.13" cy="552.121" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1326.55" cy="562.201" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1342.97" cy="573.097" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1359.38" cy="584.773" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1375.8" cy="597.19" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1392.22" cy="610.309" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1422.3" cy="636.027" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1452.38" cy="663.689" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1467.42" cy="678.161" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1482.46" cy="693.014" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1497.51" cy="708.21" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1512.55" cy="723.712" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1568.11" cy="783.038" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1623.67" cy="844.228" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1679.96" cy="906.355" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1736.24" cy="967.038" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1767.78" cy="999.895" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1799.32" cy="1031.67" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1830.86" cy="1062.2" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1862.4" cy="1091.33" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1890.98" cy="1116.43" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1919.56" cy="1140.24" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1948.14" cy="1162.71" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="1976.73" cy="1183.81" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2009.45" cy="1206.28" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2042.17" cy="1226.96" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2074.89" cy="1245.87" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2107.61" cy="1263.06" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2137.91" cy="1277.51" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2168.21" cy="1290.6" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2198.51" cy="1302.41" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2228.81" cy="1313.01" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2258.68" cy="1322.36" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2288.55" cy="1330.68" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2318.42" cy="1338.06" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<circle clip-path="url(#clip912)" cx="2348.29" cy="1344.58" r="14.4" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<polyline clip-path="url(#clip912)" style="stroke:#e26f46; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  340.028,1384.24 344.446,1384.24 348.864,1384.24 353.282,1384.24 357.7,1384.24 362.118,1384.24 366.536,1384.24 370.954,1384.23 375.372,1384.23 385.584,1384.14 
  395.797,1383.77 406.009,1382.75 416.222,1380.49 426.435,1376.31 436.647,1369.46 441.754,1364.8 446.86,1359.23 451.966,1352.67 457.073,1345.05 462.179,1336.34 
  467.285,1326.49 472.392,1315.48 477.498,1303.29 482.604,1289.93 487.711,1275.4 492.817,1259.72 497.923,1242.91 503.03,1225.02 508.136,1206.07 513.242,1186.13 
  518.349,1165.25 528.561,1120.9 538.774,1073.53 548.987,1023.71 559.199,971.995 569.412,918.958 579.625,865.146 600.05,757.238 620.475,651.956 630.688,601.259 
  640.901,552.276 651.113,505.264 661.326,460.435 671.539,417.962 681.751,377.979 691.964,340.584 702.176,305.844 708.314,286.262 714.451,267.657 720.589,250.031 
  726.726,233.381 732.863,217.704 739.001,202.992 745.138,189.236 751.276,176.426 757.413,164.548 763.55,153.589 769.688,143.533 775.825,134.363 781.962,126.061 
  788.1,118.608 794.237,111.985 800.375,106.171 812.649,96.8847 824.924,90.5773 837.199,87.0708 849.474,86.1857 861.748,87.7426 874.023,91.5641 886.298,97.4762 
  898.573,105.31 908.951,113.31 919.329,122.472 929.707,132.702 940.085,143.912 960.842,168.937 981.598,196.913 1002.35,227.269 1023.11,259.491 1043.87,293.124 
  1064.62,327.767 1109.72,404.892 1154.81,482.308 1199.91,557.969 1245,630.491 1265.79,662.605 1286.57,693.803 1307.36,724.043 1328.15,753.295 1348.93,781.541 
  1369.72,808.772 1390.51,834.986 1411.29,860.187 1433.58,886.094 1455.86,910.87 1478.15,934.537 1500.43,957.123 1522.72,978.66 1545,999.179 1567.29,1018.71 
  1589.57,1037.3 1615.39,1057.7 1641.21,1076.94 1667.03,1095.06 1692.85,1112.12 1718.67,1128.19 1744.49,1143.3 1770.31,1157.52 1796.13,1170.9 1842.02,1192.72 
  1887.91,1212.27 1933.81,1229.77 1979.7,1245.43 2019.94,1257.81 2060.18,1269.05 2100.42,1279.24 2140.67,1288.49 2184.54,1297.61 2228.42,1305.82 2272.29,1313.21 
  2316.17,1319.87 2404.44,1331.34 2492.71,1340.66 2590.3,1348.97 2687.9,1355.61 2780.76,1360.7 2873.62,1364.83 3066.72,1371.13 3229.28,1374.74 3427.73,1377.76 
  3609.54,1379.63 3777.44,1380.85 3947.53,1381.74 4138.14,1382.45 4310.87,1382.9 4508.64,1383.28 4691.75,1383.53 4872.28,1383.7 5047.55,1383.83 5227.23,1383.93 
  5424.09,1384.01 5710.07,1384.09 5768.74,1384.1 
  "/>
<path clip-path="url(#clip912)" d="M340.028 1400.24 L326.172 1392.24 L326.172 1376.24 L340.028 1368.24 L353.884 1376.24 L353.884 1392.24 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M344.446 1400.24 L330.59 1392.24 L330.59 1376.24 L344.446 1368.24 L358.302 1376.24 L358.302 1392.24 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M348.864 1400.24 L335.008 1392.24 L335.008 1376.24 L348.864 1368.24 L362.72 1376.24 L362.72 1392.24 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M353.282 1400.24 L339.426 1392.24 L339.426 1376.24 L353.282 1368.24 L367.138 1376.24 L367.138 1392.24 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M357.7 1400.24 L343.844 1392.24 L343.844 1376.24 L357.7 1368.24 L371.556 1376.24 L371.556 1392.24 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M362.118 1400.24 L348.262 1392.24 L348.262 1376.24 L362.118 1368.24 L375.974 1376.24 L375.974 1392.24 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M366.536 1400.24 L352.68 1392.24 L352.68 1376.24 L366.536 1368.24 L380.392 1376.24 L380.392 1392.24 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M370.954 1400.23 L357.098 1392.23 L357.098 1376.23 L370.954 1368.23 L384.81 1376.23 L384.81 1392.23 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M375.372 1400.23 L361.516 1392.23 L361.516 1376.23 L375.372 1368.23 L389.228 1376.23 L389.228 1392.23 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M385.584 1400.14 L371.728 1392.14 L371.728 1376.14 L385.584 1368.14 L399.44 1376.14 L399.44 1392.14 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M395.797 1399.77 L381.941 1391.77 L381.941 1375.77 L395.797 1367.77 L409.653 1375.77 L409.653 1391.77 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M406.009 1398.75 L392.153 1390.75 L392.153 1374.75 L406.009 1366.75 L419.865 1374.75 L419.865 1390.75 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M416.222 1396.49 L402.366 1388.49 L402.366 1372.49 L416.222 1364.49 L430.078 1372.49 L430.078 1388.49 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M426.435 1392.31 L412.579 1384.31 L412.579 1368.31 L426.435 1360.31 L440.291 1368.31 L440.291 1384.31 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M436.647 1385.46 L422.791 1377.46 L422.791 1361.46 L436.647 1353.46 L450.503 1361.46 L450.503 1377.46 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M441.754 1380.8 L427.898 1372.8 L427.898 1356.8 L441.754 1348.8 L455.61 1356.8 L455.61 1372.8 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M446.86 1375.23 L433.004 1367.23 L433.004 1351.23 L446.86 1343.23 L460.716 1351.23 L460.716 1367.23 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M451.966 1368.67 L438.11 1360.67 L438.11 1344.67 L451.966 1336.67 L465.822 1344.67 L465.822 1360.67 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M457.073 1361.05 L443.217 1353.05 L443.217 1337.05 L457.073 1329.05 L470.929 1337.05 L470.929 1353.05 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M462.179 1352.34 L448.323 1344.34 L448.323 1328.34 L462.179 1320.34 L476.035 1328.34 L476.035 1344.34 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M467.285 1342.49 L453.429 1334.49 L453.429 1318.49 L467.285 1310.49 L481.141 1318.49 L481.141 1334.49 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M472.392 1331.48 L458.536 1323.48 L458.536 1307.48 L472.392 1299.48 L486.248 1307.48 L486.248 1323.48 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M477.498 1319.29 L463.642 1311.29 L463.642 1295.29 L477.498 1287.29 L491.354 1295.29 L491.354 1311.29 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M482.604 1305.93 L468.748 1297.93 L468.748 1281.93 L482.604 1273.93 L496.46 1281.93 L496.46 1297.93 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M487.711 1291.4 L473.855 1283.4 L473.855 1267.4 L487.711 1259.4 L501.567 1267.4 L501.567 1283.4 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M492.817 1275.72 L478.961 1267.72 L478.961 1251.72 L492.817 1243.72 L506.673 1251.72 L506.673 1267.72 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M497.923 1258.91 L484.067 1250.91 L484.067 1234.91 L497.923 1226.91 L511.779 1234.91 L511.779 1250.91 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M503.03 1241.02 L489.174 1233.02 L489.174 1217.02 L503.03 1209.02 L516.886 1217.02 L516.886 1233.02 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M508.136 1222.07 L494.28 1214.07 L494.28 1198.07 L508.136 1190.07 L521.992 1198.07 L521.992 1214.07 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M513.242 1202.13 L499.386 1194.13 L499.386 1178.13 L513.242 1170.13 L527.098 1178.13 L527.098 1194.13 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M518.349 1181.25 L504.493 1173.25 L504.493 1157.25 L518.349 1149.25 L532.205 1157.25 L532.205 1173.25 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M528.561 1136.9 L514.705 1128.9 L514.705 1112.9 L528.561 1104.9 L542.417 1112.9 L542.417 1128.9 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M538.774 1089.53 L524.918 1081.53 L524.918 1065.53 L538.774 1057.53 L552.63 1065.53 L552.63 1081.53 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M548.987 1039.71 L535.131 1031.71 L535.131 1015.71 L548.987 1007.71 L562.843 1015.71 L562.843 1031.71 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M559.199 987.995 L545.343 979.995 L545.343 963.995 L559.199 955.995 L573.055 963.995 L573.055 979.995 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M569.412 934.958 L555.556 926.958 L555.556 910.958 L569.412 902.958 L583.268 910.958 L583.268 926.958 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M579.625 881.146 L565.769 873.146 L565.769 857.146 L579.625 849.146 L593.481 857.146 L593.481 873.146 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M600.05 773.238 L586.194 765.238 L586.194 749.238 L600.05 741.238 L613.906 749.238 L613.906 765.238 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M620.475 667.956 L606.619 659.956 L606.619 643.956 L620.475 635.956 L634.331 643.956 L634.331 659.956 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M630.688 617.259 L616.832 609.259 L616.832 593.259 L630.688 585.259 L644.544 593.259 L644.544 609.259 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M640.901 568.276 L627.045 560.276 L627.045 544.276 L640.901 536.276 L654.757 544.276 L654.757 560.276 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M651.113 521.264 L637.257 513.264 L637.257 497.264 L651.113 489.264 L664.969 497.264 L664.969 513.264 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M661.326 476.435 L647.47 468.435 L647.47 452.435 L661.326 444.435 L675.182 452.435 L675.182 468.435 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M671.539 433.962 L657.683 425.962 L657.683 409.962 L671.539 401.962 L685.395 409.962 L685.395 425.962 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M681.751 393.979 L667.895 385.979 L667.895 369.979 L681.751 361.979 L695.607 369.979 L695.607 385.979 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M691.964 356.584 L678.108 348.584 L678.108 332.584 L691.964 324.584 L705.82 332.584 L705.82 348.584 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M702.176 321.844 L688.32 313.844 L688.32 297.844 L702.176 289.844 L716.032 297.844 L716.032 313.844 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M708.314 302.262 L694.458 294.262 L694.458 278.262 L708.314 270.262 L722.17 278.262 L722.17 294.262 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M714.451 283.657 L700.595 275.657 L700.595 259.657 L714.451 251.657 L728.307 259.657 L728.307 275.657 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M720.589 266.031 L706.733 258.031 L706.733 242.031 L720.589 234.031 L734.445 242.031 L734.445 258.031 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M726.726 249.381 L712.87 241.381 L712.87 225.381 L726.726 217.381 L740.582 225.381 L740.582 241.381 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M732.863 233.704 L719.007 225.704 L719.007 209.704 L732.863 201.704 L746.719 209.704 L746.719 225.704 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M739.001 218.992 L725.145 210.992 L725.145 194.992 L739.001 186.992 L752.857 194.992 L752.857 210.992 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M745.138 205.236 L731.282 197.236 L731.282 181.236 L745.138 173.236 L758.994 181.236 L758.994 197.236 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M751.276 192.426 L737.42 184.426 L737.42 168.426 L751.276 160.426 L765.132 168.426 L765.132 184.426 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M757.413 180.548 L743.557 172.548 L743.557 156.548 L757.413 148.548 L771.269 156.548 L771.269 172.548 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M763.55 169.589 L749.694 161.589 L749.694 145.589 L763.55 137.589 L777.406 145.589 L777.406 161.589 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M769.688 159.533 L755.832 151.533 L755.832 135.533 L769.688 127.533 L783.544 135.533 L783.544 151.533 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M775.825 150.363 L761.969 142.363 L761.969 126.363 L775.825 118.363 L789.681 126.363 L789.681 142.363 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M781.962 142.061 L768.106 134.061 L768.106 118.061 L781.962 110.061 L795.818 118.061 L795.818 134.061 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M788.1 134.608 L774.244 126.608 L774.244 110.608 L788.1 102.608 L801.956 110.608 L801.956 126.608 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M794.237 127.985 L780.381 119.985 L780.381 103.985 L794.237 95.985 L808.093 103.985 L808.093 119.985 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M800.375 122.171 L786.519 114.171 L786.519 98.1707 L800.375 90.1707 L814.231 98.1707 L814.231 114.171 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M812.649 112.885 L798.793 104.885 L798.793 88.8847 L812.649 80.8847 L826.505 88.8847 L826.505 104.885 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M824.924 106.577 L811.068 98.5773 L811.068 82.5773 L824.924 74.5773 L838.78 82.5773 L838.78 98.5773 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M837.199 103.071 L823.343 95.0708 L823.343 79.0708 L837.199 71.0708 L851.055 79.0708 L851.055 95.0708 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M849.474 102.186 L835.618 94.1857 L835.618 78.1857 L849.474 70.1857 L863.33 78.1857 L863.33 94.1857 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M861.748 103.743 L847.892 95.7426 L847.892 79.7426 L861.748 71.7426 L875.604 79.7426 L875.604 95.7426 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M874.023 107.564 L860.167 99.5641 L860.167 83.5641 L874.023 75.5641 L887.879 83.5641 L887.879 99.5641 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M886.298 113.476 L872.442 105.476 L872.442 89.4762 L886.298 81.4762 L900.154 89.4762 L900.154 105.476 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M898.573 121.31 L884.717 113.31 L884.717 97.3097 L898.573 89.3097 L912.429 97.3097 L912.429 113.31 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M908.951 129.31 L895.095 121.31 L895.095 105.31 L908.951 97.3104 L922.807 105.31 L922.807 121.31 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M919.329 138.472 L905.473 130.472 L905.473 114.472 L919.329 106.472 L933.185 114.472 L933.185 130.472 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M929.707 148.702 L915.851 140.702 L915.851 124.702 L929.707 116.702 L943.563 124.702 L943.563 140.702 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M940.085 159.912 L926.229 151.912 L926.229 135.912 L940.085 127.912 L953.941 135.912 L953.941 151.912 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M960.842 184.937 L946.986 176.937 L946.986 160.937 L960.842 152.937 L974.698 160.937 L974.698 176.937 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M981.598 212.913 L967.742 204.913 L967.742 188.913 L981.598 180.913 L995.454 188.913 L995.454 204.913 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1002.35 243.269 L988.498 235.269 L988.498 219.269 L1002.35 211.269 L1016.21 219.269 L1016.21 235.269 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1023.11 275.491 L1009.25 267.491 L1009.25 251.491 L1023.11 243.491 L1036.97 251.491 L1036.97 267.491 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1043.87 309.124 L1030.01 301.124 L1030.01 285.124 L1043.87 277.124 L1057.72 285.124 L1057.72 301.124 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1064.62 343.767 L1050.77 335.767 L1050.77 319.767 L1064.62 311.767 L1078.48 319.767 L1078.48 335.767 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1109.72 420.892 L1095.86 412.892 L1095.86 396.892 L1109.72 388.892 L1123.57 396.892 L1123.57 412.892 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1154.81 498.308 L1140.96 490.308 L1140.96 474.308 L1154.81 466.308 L1168.67 474.308 L1168.67 490.308 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1199.91 573.969 L1186.05 565.969 L1186.05 549.969 L1199.91 541.969 L1213.76 549.969 L1213.76 565.969 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1245 646.491 L1231.14 638.491 L1231.14 622.491 L1245 614.491 L1258.86 622.491 L1258.86 638.491 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1265.79 678.605 L1251.93 670.605 L1251.93 654.605 L1265.79 646.605 L1279.64 654.605 L1279.64 670.605 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1286.57 709.803 L1272.72 701.803 L1272.72 685.803 L1286.57 677.803 L1300.43 685.803 L1300.43 701.803 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1307.36 740.043 L1293.5 732.043 L1293.5 716.043 L1307.36 708.043 L1321.22 716.043 L1321.22 732.043 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1328.15 769.295 L1314.29 761.295 L1314.29 745.295 L1328.15 737.295 L1342 745.295 L1342 761.295 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1348.93 797.541 L1335.08 789.541 L1335.08 773.541 L1348.93 765.541 L1362.79 773.541 L1362.79 789.541 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1369.72 824.772 L1355.86 816.772 L1355.86 800.772 L1369.72 792.772 L1383.58 800.772 L1383.58 816.772 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1390.51 850.986 L1376.65 842.986 L1376.65 826.986 L1390.51 818.986 L1404.36 826.986 L1404.36 842.986 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1411.29 876.187 L1397.44 868.187 L1397.44 852.187 L1411.29 844.187 L1425.15 852.187 L1425.15 868.187 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1433.58 902.094 L1419.72 894.094 L1419.72 878.094 L1433.58 870.094 L1447.43 878.094 L1447.43 894.094 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1455.86 926.87 L1442.01 918.87 L1442.01 902.87 L1455.86 894.87 L1469.72 902.87 L1469.72 918.87 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1478.15 950.537 L1464.29 942.537 L1464.29 926.537 L1478.15 918.537 L1492 926.537 L1492 942.537 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1500.43 973.123 L1486.58 965.123 L1486.58 949.123 L1500.43 941.123 L1514.29 949.123 L1514.29 965.123 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1522.72 994.66 L1508.86 986.66 L1508.86 970.66 L1522.72 962.66 L1536.57 970.66 L1536.57 986.66 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1545 1015.18 L1531.15 1007.18 L1531.15 991.179 L1545 983.179 L1558.86 991.179 L1558.86 1007.18 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1567.29 1034.71 L1553.43 1026.71 L1553.43 1010.71 L1567.29 1002.71 L1581.15 1010.71 L1581.15 1026.71 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1589.57 1053.3 L1575.72 1045.3 L1575.72 1029.3 L1589.57 1021.3 L1603.43 1029.3 L1603.43 1045.3 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1615.39 1073.7 L1601.54 1065.7 L1601.54 1049.7 L1615.39 1041.7 L1629.25 1049.7 L1629.25 1065.7 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1641.21 1092.94 L1627.36 1084.94 L1627.36 1068.94 L1641.21 1060.94 L1655.07 1068.94 L1655.07 1084.94 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1667.03 1111.06 L1653.18 1103.06 L1653.18 1087.06 L1667.03 1079.06 L1680.89 1087.06 L1680.89 1103.06 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1692.85 1128.12 L1679 1120.12 L1679 1104.12 L1692.85 1096.12 L1706.71 1104.12 L1706.71 1120.12 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1718.67 1144.19 L1704.82 1136.19 L1704.82 1120.19 L1718.67 1112.19 L1732.53 1120.19 L1732.53 1136.19 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1744.49 1159.3 L1730.64 1151.3 L1730.64 1135.3 L1744.49 1127.3 L1758.35 1135.3 L1758.35 1151.3 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1770.31 1173.52 L1756.46 1165.52 L1756.46 1149.52 L1770.31 1141.52 L1784.17 1149.52 L1784.17 1165.52 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1796.13 1186.9 L1782.28 1178.9 L1782.28 1162.9 L1796.13 1154.9 L1809.99 1162.9 L1809.99 1178.9 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1842.02 1208.72 L1828.17 1200.72 L1828.17 1184.72 L1842.02 1176.72 L1855.88 1184.72 L1855.88 1200.72 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1887.91 1228.27 L1874.06 1220.27 L1874.06 1204.27 L1887.91 1196.27 L1901.77 1204.27 L1901.77 1220.27 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1933.81 1245.77 L1919.95 1237.77 L1919.95 1221.77 L1933.81 1213.77 L1947.66 1221.77 L1947.66 1237.77 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M1979.7 1261.43 L1965.84 1253.43 L1965.84 1237.43 L1979.7 1229.43 L1993.55 1237.43 L1993.55 1253.43 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M2019.94 1273.81 L2006.08 1265.81 L2006.08 1249.81 L2019.94 1241.81 L2033.8 1249.81 L2033.8 1265.81 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M2060.18 1285.05 L2046.33 1277.05 L2046.33 1261.05 L2060.18 1253.05 L2074.04 1261.05 L2074.04 1277.05 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M2100.42 1295.24 L2086.57 1287.24 L2086.57 1271.24 L2100.42 1263.24 L2114.28 1271.24 L2114.28 1287.24 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M2140.67 1304.49 L2126.81 1296.49 L2126.81 1280.49 L2140.67 1272.49 L2154.52 1280.49 L2154.52 1296.49 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M2184.54 1313.61 L2170.69 1305.61 L2170.69 1289.61 L2184.54 1281.61 L2198.4 1289.61 L2198.4 1305.61 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M2228.42 1321.82 L2214.56 1313.82 L2214.56 1297.82 L2228.42 1289.82 L2242.27 1297.82 L2242.27 1313.82 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M2272.29 1329.21 L2258.43 1321.21 L2258.43 1305.21 L2272.29 1297.21 L2286.15 1305.21 L2286.15 1321.21 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip912)" d="M2316.17 1335.87 L2302.31 1327.87 L2302.31 1311.87 L2316.17 1303.87 L2330.02 1311.87 L2330.02 1327.87 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="3.2"/>
<path clip-path="url(#clip910)" d="
M1128.77 248.629 L2285.66 248.629 L2285.66 93.1086 L1128.77 93.1086  Z
  " fill="#ffffff" fill-rule="evenodd" fill-opacity="1"/>
<polyline clip-path="url(#clip910)" style="stroke:#000000; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  1128.77,248.629 2285.66,248.629 2285.66,93.1086 1128.77,93.1086 1128.77,248.629 
  "/>
<polyline clip-path="url(#clip910)" style="stroke:#009af9; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  1151.13,144.949 1285.32,144.949 
  "/>
<circle clip-path="url(#clip910)" cx="1218.22" cy="144.949" r="23.04" fill="#009af9" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="5.12"/>
<path clip-path="url(#clip910)" d="M1307.68 127.669 L1313.98 127.669 L1329.3 156.581 L1329.3 127.669 L1333.84 127.669 L1333.84 162.229 L1327.54 162.229 L1312.22 133.317 L1312.22 162.229 L1307.68 162.229 L1307.68 127.669 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1353 139.289 Q1349.58 139.289 1347.59 141.974 Q1345.6 144.636 1345.6 149.289 Q1345.6 153.942 1347.56 156.627 Q1349.55 159.289 1353 159.289 Q1356.41 159.289 1358.4 156.604 Q1360.39 153.918 1360.39 149.289 Q1360.39 144.682 1358.4 141.997 Q1356.41 139.289 1353 139.289 M1353 135.678 Q1358.56 135.678 1361.73 139.289 Q1364.9 142.9 1364.9 149.289 Q1364.9 155.655 1361.73 159.289 Q1358.56 162.9 1353 162.9 Q1347.42 162.9 1344.25 159.289 Q1341.1 155.655 1341.1 149.289 Q1341.1 142.9 1344.25 139.289 Q1347.42 135.678 1353 135.678 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1386.98 140.284 Q1386.27 139.868 1385.41 139.682 Q1384.58 139.474 1383.56 139.474 Q1379.95 139.474 1378 141.835 Q1376.08 144.173 1376.08 148.571 L1376.08 162.229 L1371.8 162.229 L1371.8 136.303 L1376.08 136.303 L1376.08 140.331 Q1377.42 137.969 1379.58 136.835 Q1381.73 135.678 1384.81 135.678 Q1385.25 135.678 1385.78 135.747 Q1386.31 135.794 1386.96 135.909 L1386.98 140.284 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1410.8 141.28 Q1412.4 138.409 1414.62 137.044 Q1416.84 135.678 1419.85 135.678 Q1423.91 135.678 1426.1 138.525 Q1428.3 141.349 1428.3 146.581 L1428.3 162.229 L1424.02 162.229 L1424.02 146.719 Q1424.02 142.993 1422.7 141.187 Q1421.38 139.382 1418.67 139.382 Q1415.36 139.382 1413.44 141.581 Q1411.52 143.78 1411.52 147.576 L1411.52 162.229 L1407.24 162.229 L1407.24 146.719 Q1407.24 142.969 1405.92 141.187 Q1404.6 139.382 1401.84 139.382 Q1398.58 139.382 1396.66 141.604 Q1394.74 143.803 1394.74 147.576 L1394.74 162.229 L1390.46 162.229 L1390.46 136.303 L1394.74 136.303 L1394.74 140.331 Q1396.2 137.946 1398.23 136.812 Q1400.27 135.678 1403.07 135.678 Q1405.9 135.678 1407.86 137.113 Q1409.85 138.548 1410.8 141.28 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1448.58 149.196 Q1443.42 149.196 1441.43 150.377 Q1439.44 151.557 1439.44 154.405 Q1439.44 156.673 1440.92 158.016 Q1442.42 159.335 1444.99 159.335 Q1448.53 159.335 1450.66 156.835 Q1452.82 154.312 1452.82 150.145 L1452.82 149.196 L1448.58 149.196 M1457.08 147.437 L1457.08 162.229 L1452.82 162.229 L1452.82 158.293 Q1451.36 160.655 1449.18 161.789 Q1447.01 162.9 1443.86 162.9 Q1439.88 162.9 1437.52 160.678 Q1435.18 158.432 1435.18 154.682 Q1435.18 150.307 1438.09 148.085 Q1441.03 145.863 1446.84 145.863 L1452.82 145.863 L1452.82 145.446 Q1452.82 142.507 1450.87 140.909 Q1448.95 139.289 1445.46 139.289 Q1443.23 139.289 1441.13 139.821 Q1439.02 140.354 1437.08 141.419 L1437.08 137.483 Q1439.41 136.581 1441.61 136.141 Q1443.81 135.678 1445.9 135.678 Q1451.52 135.678 1454.3 138.594 Q1457.08 141.511 1457.08 147.437 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1465.85 126.21 L1470.11 126.21 L1470.11 162.229 L1465.85 162.229 L1465.85 126.21 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1489.25 126.257 Q1486.15 131.581 1484.65 136.789 Q1483.14 141.997 1483.14 147.344 Q1483.14 152.692 1484.65 157.946 Q1486.17 163.178 1489.25 168.479 L1485.55 168.479 Q1482.08 163.039 1480.34 157.784 Q1478.63 152.53 1478.63 147.344 Q1478.63 142.182 1480.34 136.951 Q1482.05 131.72 1485.55 126.257 L1489.25 126.257 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1497.7 127.669 L1504 127.669 L1519.32 156.581 L1519.32 127.669 L1523.86 127.669 L1523.86 162.229 L1517.56 162.229 L1502.24 133.317 L1502.24 162.229 L1497.7 162.229 L1497.7 127.669 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1543.02 139.289 Q1539.6 139.289 1537.61 141.974 Q1535.62 144.636 1535.62 149.289 Q1535.62 153.942 1537.58 156.627 Q1539.58 159.289 1543.02 159.289 Q1546.43 159.289 1548.42 156.604 Q1550.41 153.918 1550.41 149.289 Q1550.41 144.682 1548.42 141.997 Q1546.43 139.289 1543.02 139.289 M1543.02 135.678 Q1548.58 135.678 1551.75 139.289 Q1554.92 142.9 1554.92 149.289 Q1554.92 155.655 1551.75 159.289 Q1548.58 162.9 1543.02 162.9 Q1537.45 162.9 1534.27 159.289 Q1531.13 155.655 1531.13 149.289 Q1531.13 142.9 1534.27 139.289 Q1537.45 135.678 1543.02 135.678 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1577.01 140.284 Q1576.29 139.868 1575.43 139.682 Q1574.6 139.474 1573.58 139.474 Q1569.97 139.474 1568.02 141.835 Q1566.1 144.173 1566.1 148.571 L1566.1 162.229 L1561.82 162.229 L1561.82 136.303 L1566.1 136.303 L1566.1 140.331 Q1567.45 137.969 1569.6 136.835 Q1571.75 135.678 1574.83 135.678 Q1575.27 135.678 1575.8 135.747 Q1576.33 135.794 1576.98 135.909 L1577.01 140.284 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1600.83 141.28 Q1602.42 138.409 1604.64 137.044 Q1606.87 135.678 1609.88 135.678 Q1613.93 135.678 1616.13 138.525 Q1618.33 141.349 1618.33 146.581 L1618.33 162.229 L1614.04 162.229 L1614.04 146.719 Q1614.04 142.993 1612.72 141.187 Q1611.4 139.382 1608.7 139.382 Q1605.39 139.382 1603.46 141.581 Q1601.54 143.78 1601.54 147.576 L1601.54 162.229 L1597.26 162.229 L1597.26 146.719 Q1597.26 142.969 1595.94 141.187 Q1594.62 139.382 1591.87 139.382 Q1588.6 139.382 1586.68 141.604 Q1584.76 143.803 1584.76 147.576 L1584.76 162.229 L1580.48 162.229 L1580.48 136.303 L1584.76 136.303 L1584.76 140.331 Q1586.22 137.946 1588.26 136.812 Q1590.29 135.678 1593.09 135.678 Q1595.92 135.678 1597.89 137.113 Q1599.88 138.548 1600.83 141.28 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1638.6 149.196 Q1633.44 149.196 1631.45 150.377 Q1629.46 151.557 1629.46 154.405 Q1629.46 156.673 1630.94 158.016 Q1632.45 159.335 1635.01 159.335 Q1638.56 159.335 1640.69 156.835 Q1642.84 154.312 1642.84 150.145 L1642.84 149.196 L1638.6 149.196 M1647.1 147.437 L1647.1 162.229 L1642.84 162.229 L1642.84 158.293 Q1641.38 160.655 1639.2 161.789 Q1637.03 162.9 1633.88 162.9 Q1629.9 162.9 1627.54 160.678 Q1625.2 158.432 1625.2 154.682 Q1625.2 150.307 1628.12 148.085 Q1631.06 145.863 1636.87 145.863 L1642.84 145.863 L1642.84 145.446 Q1642.84 142.507 1640.89 140.909 Q1638.97 139.289 1635.48 139.289 Q1633.26 139.289 1631.15 139.821 Q1629.04 140.354 1627.1 141.419 L1627.1 137.483 Q1629.44 136.581 1631.64 136.141 Q1633.83 135.678 1635.92 135.678 Q1641.54 135.678 1644.32 138.594 Q1647.1 141.511 1647.1 147.437 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1655.87 126.21 L1660.13 126.21 L1660.13 162.229 L1655.87 162.229 L1655.87 126.21 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1679.27 126.257 Q1676.17 131.581 1674.67 136.789 Q1673.16 141.997 1673.16 147.344 Q1673.16 152.692 1674.67 157.946 Q1676.2 163.178 1679.27 168.479 L1675.57 168.479 Q1672.1 163.039 1670.36 157.784 Q1668.65 152.53 1668.65 147.344 Q1668.65 142.182 1670.36 136.951 Q1672.07 131.72 1675.57 126.257 L1679.27 126.257 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1688.95 158.293 L1696.59 158.293 L1696.59 131.928 L1688.28 133.595 L1688.28 129.335 L1696.54 127.669 L1701.22 127.669 L1701.22 158.293 L1708.86 158.293 L1708.86 162.229 L1688.95 162.229 L1688.95 158.293 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1728.3 130.747 Q1724.69 130.747 1722.86 134.312 Q1721.06 137.854 1721.06 144.983 Q1721.06 152.09 1722.86 155.655 Q1724.69 159.196 1728.3 159.196 Q1731.94 159.196 1733.74 155.655 Q1735.57 152.09 1735.57 144.983 Q1735.57 137.854 1733.74 134.312 Q1731.94 130.747 1728.3 130.747 M1728.3 127.044 Q1734.11 127.044 1737.17 131.65 Q1740.25 136.233 1740.25 144.983 Q1740.25 153.71 1737.17 158.317 Q1734.11 162.9 1728.3 162.9 Q1722.49 162.9 1719.41 158.317 Q1716.36 153.71 1716.36 144.983 Q1716.36 136.233 1719.41 131.65 Q1722.49 127.044 1728.3 127.044 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1758.46 130.747 Q1754.85 130.747 1753.02 134.312 Q1751.22 137.854 1751.22 144.983 Q1751.22 152.09 1753.02 155.655 Q1754.85 159.196 1758.46 159.196 Q1762.1 159.196 1763.9 155.655 Q1765.73 152.09 1765.73 144.983 Q1765.73 137.854 1763.9 134.312 Q1762.1 130.747 1758.46 130.747 M1758.46 127.044 Q1764.27 127.044 1767.33 131.65 Q1770.41 136.233 1770.41 144.983 Q1770.41 153.71 1767.33 158.317 Q1764.27 162.9 1758.46 162.9 Q1752.65 162.9 1749.57 158.317 Q1746.52 153.71 1746.52 144.983 Q1746.52 136.233 1749.57 131.65 Q1752.65 127.044 1758.46 127.044 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1788.63 130.747 Q1785.01 130.747 1783.19 134.312 Q1781.38 137.854 1781.38 144.983 Q1781.38 152.09 1783.19 155.655 Q1785.01 159.196 1788.63 159.196 Q1792.26 159.196 1794.07 155.655 Q1795.89 152.09 1795.89 144.983 Q1795.89 137.854 1794.07 134.312 Q1792.26 130.747 1788.63 130.747 M1788.63 127.044 Q1794.44 127.044 1797.49 131.65 Q1800.57 136.233 1800.57 144.983 Q1800.57 153.71 1797.49 158.317 Q1794.44 162.9 1788.63 162.9 Q1782.82 162.9 1779.74 158.317 Q1776.68 153.71 1776.68 144.983 Q1776.68 136.233 1779.74 131.65 Q1782.82 127.044 1788.63 127.044 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1809.27 156.349 L1814.16 156.349 L1814.16 160.33 L1810.36 167.738 L1807.38 167.738 L1809.27 160.33 L1809.27 156.349 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1849.5 143.085 Q1846.36 143.085 1844.5 145.238 Q1842.68 147.391 1842.68 151.141 Q1842.68 154.868 1844.5 157.043 Q1846.36 159.196 1849.5 159.196 Q1852.65 159.196 1854.48 157.043 Q1856.33 154.868 1856.33 151.141 Q1856.33 147.391 1854.48 145.238 Q1852.65 143.085 1849.5 143.085 M1858.79 128.433 L1858.79 132.692 Q1857.03 131.858 1855.22 131.419 Q1853.44 130.979 1851.68 130.979 Q1847.05 130.979 1844.6 134.104 Q1842.17 137.229 1841.82 143.548 Q1843.19 141.534 1845.25 140.469 Q1847.31 139.382 1849.78 139.382 Q1854.99 139.382 1858 142.553 Q1861.03 145.701 1861.03 151.141 Q1861.03 156.465 1857.88 159.682 Q1854.74 162.9 1849.5 162.9 Q1843.51 162.9 1840.34 158.317 Q1837.17 153.71 1837.17 144.983 Q1837.17 136.789 1841.06 131.928 Q1844.94 127.044 1851.5 127.044 Q1853.25 127.044 1855.04 127.391 Q1856.84 127.738 1858.79 128.433 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1879.09 130.747 Q1875.48 130.747 1873.65 134.312 Q1871.84 137.854 1871.84 144.983 Q1871.84 152.09 1873.65 155.655 Q1875.48 159.196 1879.09 159.196 Q1882.72 159.196 1884.53 155.655 Q1886.36 152.09 1886.36 144.983 Q1886.36 137.854 1884.53 134.312 Q1882.72 130.747 1879.09 130.747 M1879.09 127.044 Q1884.9 127.044 1887.95 131.65 Q1891.03 136.233 1891.03 144.983 Q1891.03 153.71 1887.95 158.317 Q1884.9 162.9 1879.09 162.9 Q1873.28 162.9 1870.2 158.317 Q1867.14 153.71 1867.14 144.983 Q1867.14 136.233 1870.2 131.65 Q1873.28 127.044 1879.09 127.044 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1909.25 130.747 Q1905.64 130.747 1903.81 134.312 Q1902 137.854 1902 144.983 Q1902 152.09 1903.81 155.655 Q1905.64 159.196 1909.25 159.196 Q1912.88 159.196 1914.69 155.655 Q1916.52 152.09 1916.52 144.983 Q1916.52 137.854 1914.69 134.312 Q1912.88 130.747 1909.25 130.747 M1909.25 127.044 Q1915.06 127.044 1918.12 131.65 Q1921.19 136.233 1921.19 144.983 Q1921.19 153.71 1918.12 158.317 Q1915.06 162.9 1909.25 162.9 Q1903.44 162.9 1900.36 158.317 Q1897.31 153.71 1897.31 144.983 Q1897.31 136.233 1900.36 131.65 Q1903.44 127.044 1909.25 127.044 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1928.14 126.257 L1931.84 126.257 Q1935.31 131.72 1937.03 136.951 Q1938.76 142.182 1938.76 147.344 Q1938.76 152.53 1937.03 157.784 Q1935.31 163.039 1931.84 168.479 L1928.14 168.479 Q1931.22 163.178 1932.72 157.946 Q1934.25 152.692 1934.25 147.344 Q1934.25 141.997 1932.72 136.789 Q1931.22 131.581 1928.14 126.257 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1946.63 126.257 L1950.34 126.257 Q1953.81 131.72 1955.52 136.951 Q1957.26 142.182 1957.26 147.344 Q1957.26 152.53 1955.52 157.784 Q1953.81 163.039 1950.34 168.479 L1946.63 168.479 Q1949.71 163.178 1951.22 157.946 Q1952.74 152.692 1952.74 147.344 Q1952.74 141.997 1951.22 136.789 Q1949.71 131.581 1946.63 126.257 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><polyline clip-path="url(#clip910)" style="stroke:#e26f46; stroke-linecap:butt; stroke-linejoin:round; stroke-width:4; stroke-opacity:1; fill:none" points="
  1151.13,196.789 1285.32,196.789 
  "/>
<path clip-path="url(#clip910)" d="M1218.22 222.389 L1196.05 209.589 L1196.05 183.989 L1218.22 171.189 L1240.39 183.989 L1240.39 209.589 Z" fill="#e26f46" fill-rule="evenodd" fill-opacity="1" stroke="#000000" stroke-opacity="1" stroke-width="5.12"/>
<path clip-path="url(#clip910)" d="M1307.68 179.509 L1312.35 179.509 L1312.35 210.133 L1329.18 210.133 L1329.18 214.069 L1307.68 214.069 L1307.68 179.509 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1343.12 191.129 Q1339.69 191.129 1337.7 193.814 Q1335.71 196.476 1335.71 201.129 Q1335.71 205.782 1337.68 208.467 Q1339.67 211.129 1343.12 211.129 Q1346.52 211.129 1348.51 208.444 Q1350.5 205.758 1350.5 201.129 Q1350.5 196.522 1348.51 193.837 Q1346.52 191.129 1343.12 191.129 M1343.12 187.518 Q1348.67 187.518 1351.85 191.129 Q1355.02 194.74 1355.02 201.129 Q1355.02 207.495 1351.85 211.129 Q1348.67 214.74 1343.12 214.74 Q1337.54 214.74 1334.37 211.129 Q1331.22 207.495 1331.22 201.129 Q1331.22 194.74 1334.37 191.129 Q1337.54 187.518 1343.12 187.518 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1379.14 200.805 Q1379.14 196.175 1377.22 193.629 Q1375.32 191.083 1371.87 191.083 Q1368.44 191.083 1366.52 193.629 Q1364.62 196.175 1364.62 200.805 Q1364.62 205.411 1366.52 207.958 Q1368.44 210.504 1371.87 210.504 Q1375.32 210.504 1377.22 207.958 Q1379.14 205.411 1379.14 200.805 M1383.4 210.851 Q1383.4 217.471 1380.46 220.689 Q1377.52 223.93 1371.45 223.93 Q1369.21 223.93 1367.22 223.582 Q1365.22 223.258 1363.35 222.564 L1363.35 218.42 Q1365.22 219.439 1367.05 219.925 Q1368.88 220.411 1370.78 220.411 Q1374.97 220.411 1377.05 218.212 Q1379.14 216.036 1379.14 211.615 L1379.14 209.508 Q1377.82 211.8 1375.76 212.934 Q1373.7 214.069 1370.83 214.069 Q1366.06 214.069 1363.14 210.434 Q1360.22 206.8 1360.22 200.805 Q1360.22 194.786 1363.14 191.152 Q1366.06 187.518 1370.83 187.518 Q1373.7 187.518 1375.76 188.652 Q1377.82 189.786 1379.14 192.078 L1379.14 188.143 L1383.4 188.143 L1383.4 210.851 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1392.35 179.509 L1398.65 179.509 L1413.97 208.421 L1413.97 179.509 L1418.51 179.509 L1418.51 214.069 L1412.22 214.069 L1396.89 185.157 L1396.89 214.069 L1392.35 214.069 L1392.35 179.509 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1437.68 191.129 Q1434.25 191.129 1432.26 193.814 Q1430.27 196.476 1430.27 201.129 Q1430.27 205.782 1432.24 208.467 Q1434.23 211.129 1437.68 211.129 Q1441.08 211.129 1443.07 208.444 Q1445.06 205.758 1445.06 201.129 Q1445.06 196.522 1443.07 193.837 Q1441.08 191.129 1437.68 191.129 M1437.68 187.518 Q1443.23 187.518 1446.4 191.129 Q1449.58 194.74 1449.58 201.129 Q1449.58 207.495 1446.4 211.129 Q1443.23 214.74 1437.68 214.74 Q1432.1 214.74 1428.93 211.129 Q1425.78 207.495 1425.78 201.129 Q1425.78 194.74 1428.93 191.129 Q1432.1 187.518 1437.68 187.518 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1471.66 192.124 Q1470.94 191.708 1470.09 191.522 Q1469.25 191.314 1468.23 191.314 Q1464.62 191.314 1462.68 193.675 Q1460.76 196.013 1460.76 200.411 L1460.76 214.069 L1456.47 214.069 L1456.47 188.143 L1460.76 188.143 L1460.76 192.171 Q1462.1 189.809 1464.25 188.675 Q1466.4 187.518 1469.48 187.518 Q1469.92 187.518 1470.46 187.587 Q1470.99 187.634 1471.64 187.749 L1471.66 192.124 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1495.48 193.12 Q1497.08 190.249 1499.3 188.884 Q1501.52 187.518 1504.53 187.518 Q1508.58 187.518 1510.78 190.365 Q1512.98 193.189 1512.98 198.421 L1512.98 214.069 L1508.7 214.069 L1508.7 198.559 Q1508.7 194.833 1507.38 193.027 Q1506.06 191.222 1503.35 191.222 Q1500.04 191.222 1498.12 193.421 Q1496.2 195.62 1496.2 199.416 L1496.2 214.069 L1491.91 214.069 L1491.91 198.559 Q1491.91 194.809 1490.59 193.027 Q1489.28 191.222 1486.52 191.222 Q1483.26 191.222 1481.34 193.444 Q1479.41 195.643 1479.41 199.416 L1479.41 214.069 L1475.13 214.069 L1475.13 188.143 L1479.41 188.143 L1479.41 192.171 Q1480.87 189.786 1482.91 188.652 Q1484.95 187.518 1487.75 187.518 Q1490.57 187.518 1492.54 188.953 Q1494.53 190.388 1495.48 193.12 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1533.26 201.036 Q1528.09 201.036 1526.1 202.217 Q1524.11 203.397 1524.11 206.245 Q1524.11 208.513 1525.59 209.856 Q1527.1 211.175 1529.67 211.175 Q1533.21 211.175 1535.34 208.675 Q1537.49 206.152 1537.49 201.985 L1537.49 201.036 L1533.26 201.036 M1541.75 199.277 L1541.75 214.069 L1537.49 214.069 L1537.49 210.133 Q1536.03 212.495 1533.86 213.629 Q1531.68 214.74 1528.53 214.74 Q1524.55 214.74 1522.19 212.518 Q1519.85 210.272 1519.85 206.522 Q1519.85 202.147 1522.77 199.925 Q1525.71 197.703 1531.52 197.703 L1537.49 197.703 L1537.49 197.286 Q1537.49 194.347 1535.55 192.749 Q1533.63 191.129 1530.13 191.129 Q1527.91 191.129 1525.8 191.661 Q1523.7 192.194 1521.75 193.259 L1521.75 189.323 Q1524.09 188.421 1526.29 187.981 Q1528.49 187.518 1530.57 187.518 Q1536.2 187.518 1538.97 190.434 Q1541.75 193.351 1541.75 199.277 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1550.52 178.05 L1554.78 178.05 L1554.78 214.069 L1550.52 214.069 L1550.52 178.05 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1583.46 218.467 L1583.46 221.8 L1582.03 221.8 Q1576.27 221.8 1574.3 220.087 Q1572.35 218.374 1572.35 213.258 L1572.35 207.726 Q1572.35 204.231 1571.1 202.888 Q1569.85 201.546 1566.57 201.546 L1565.15 201.546 L1565.15 198.235 L1566.57 198.235 Q1569.88 198.235 1571.1 196.916 Q1572.35 195.573 1572.35 192.124 L1572.35 186.569 Q1572.35 181.453 1574.3 179.763 Q1576.27 178.05 1582.03 178.05 L1583.46 178.05 L1583.46 181.36 L1581.89 181.36 Q1578.63 181.36 1577.63 182.379 Q1576.64 183.397 1576.64 186.661 L1576.64 192.402 Q1576.64 196.036 1575.57 197.68 Q1574.53 199.323 1571.98 199.902 Q1574.55 200.527 1575.59 202.171 Q1576.64 203.814 1576.64 207.425 L1576.64 213.166 Q1576.64 216.43 1577.63 217.448 Q1578.63 218.467 1581.89 218.467 L1583.46 218.467 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1594.04 179.509 L1613.9 179.509 L1613.9 183.444 L1598.72 183.444 L1598.72 193.629 L1612.42 193.629 L1612.42 197.564 L1598.72 197.564 L1598.72 214.069 L1594.04 214.069 L1594.04 179.509 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1621.13 178.05 L1625.39 178.05 L1625.39 214.069 L1621.13 214.069 L1621.13 178.05 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1644.34 191.129 Q1640.92 191.129 1638.93 193.814 Q1636.94 196.476 1636.94 201.129 Q1636.94 205.782 1638.9 208.467 Q1640.89 211.129 1644.34 211.129 Q1647.75 211.129 1649.74 208.444 Q1651.73 205.758 1651.73 201.129 Q1651.73 196.522 1649.74 193.837 Q1647.75 191.129 1644.34 191.129 M1644.34 187.518 Q1649.9 187.518 1653.07 191.129 Q1656.24 194.74 1656.24 201.129 Q1656.24 207.495 1653.07 211.129 Q1649.9 214.74 1644.34 214.74 Q1638.76 214.74 1635.59 211.129 Q1632.45 207.495 1632.45 201.129 Q1632.45 194.74 1635.59 191.129 Q1638.76 187.518 1644.34 187.518 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1675.08 201.036 Q1669.92 201.036 1667.93 202.217 Q1665.94 203.397 1665.94 206.245 Q1665.94 208.513 1667.42 209.856 Q1668.93 211.175 1671.5 211.175 Q1675.04 211.175 1677.17 208.675 Q1679.32 206.152 1679.32 201.985 L1679.32 201.036 L1675.08 201.036 M1683.58 199.277 L1683.58 214.069 L1679.32 214.069 L1679.32 210.133 Q1677.86 212.495 1675.69 213.629 Q1673.51 214.74 1670.36 214.74 Q1666.38 214.74 1664.02 212.518 Q1661.68 210.272 1661.68 206.522 Q1661.68 202.147 1664.6 199.925 Q1667.54 197.703 1673.35 197.703 L1679.32 197.703 L1679.32 197.286 Q1679.32 194.347 1677.38 192.749 Q1675.45 191.129 1671.96 191.129 Q1669.74 191.129 1667.63 191.661 Q1665.52 192.194 1663.58 193.259 L1663.58 189.323 Q1665.92 188.421 1668.12 187.981 Q1670.32 187.518 1672.4 187.518 Q1678.02 187.518 1680.8 190.434 Q1683.58 193.351 1683.58 199.277 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1696.57 180.782 L1696.57 188.143 L1705.34 188.143 L1705.34 191.453 L1696.57 191.453 L1696.57 205.527 Q1696.57 208.698 1697.42 209.601 Q1698.3 210.504 1700.96 210.504 L1705.34 210.504 L1705.34 214.069 L1700.96 214.069 Q1696.03 214.069 1694.16 212.24 Q1692.28 210.388 1692.28 205.527 L1692.28 191.453 L1689.16 191.453 L1689.16 188.143 L1692.28 188.143 L1692.28 180.782 L1696.57 180.782 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1722.12 194.925 Q1718.97 194.925 1717.12 197.078 Q1715.29 199.231 1715.29 202.981 Q1715.29 206.708 1717.12 208.883 Q1718.97 211.036 1722.12 211.036 Q1725.27 211.036 1727.1 208.883 Q1728.95 206.708 1728.95 202.981 Q1728.95 199.231 1727.1 197.078 Q1725.27 194.925 1722.12 194.925 M1731.4 180.273 L1731.4 184.532 Q1729.64 183.698 1727.84 183.259 Q1726.06 182.819 1724.3 182.819 Q1719.67 182.819 1717.21 185.944 Q1714.78 189.069 1714.44 195.388 Q1715.8 193.374 1717.86 192.309 Q1719.92 191.222 1722.4 191.222 Q1727.61 191.222 1730.62 194.393 Q1733.65 197.541 1733.65 202.981 Q1733.65 208.305 1730.5 211.522 Q1727.35 214.74 1722.12 214.74 Q1716.13 214.74 1712.95 210.157 Q1709.78 205.55 1709.78 196.823 Q1709.78 188.629 1713.67 183.768 Q1717.56 178.884 1724.11 178.884 Q1725.87 178.884 1727.65 179.231 Q1729.46 179.578 1731.4 180.273 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1754.55 183.583 L1742.75 202.032 L1754.55 202.032 L1754.55 183.583 M1753.32 179.509 L1759.2 179.509 L1759.2 202.032 L1764.13 202.032 L1764.13 205.921 L1759.2 205.921 L1759.2 214.069 L1754.55 214.069 L1754.55 205.921 L1738.95 205.921 L1738.95 201.407 L1753.32 179.509 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1772.72 218.467 L1774.34 218.467 Q1777.58 218.467 1778.56 217.471 Q1779.55 216.476 1779.55 213.166 L1779.55 207.425 Q1779.55 203.814 1780.59 202.171 Q1781.63 200.527 1784.2 199.902 Q1781.63 199.323 1780.59 197.68 Q1779.55 196.036 1779.55 192.402 L1779.55 186.661 Q1779.55 183.374 1778.56 182.379 Q1777.58 181.36 1774.34 181.36 L1772.72 181.36 L1772.72 178.05 L1774.18 178.05 Q1779.94 178.05 1781.87 179.763 Q1783.81 181.453 1783.81 186.569 L1783.81 192.124 Q1783.81 195.573 1785.06 196.916 Q1786.31 198.235 1789.6 198.235 L1791.03 198.235 L1791.03 201.546 L1789.6 201.546 Q1786.31 201.546 1785.06 202.888 Q1783.81 204.231 1783.81 207.726 L1783.81 213.258 Q1783.81 218.374 1781.87 220.087 Q1779.94 221.8 1774.18 221.8 L1772.72 221.8 L1772.72 218.467 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1811.66 178.097 Q1808.56 183.421 1807.05 188.629 Q1805.55 193.837 1805.55 199.184 Q1805.55 204.532 1807.05 209.786 Q1808.58 215.018 1811.66 220.319 L1807.95 220.319 Q1804.48 214.879 1802.75 209.624 Q1801.03 204.37 1801.03 199.184 Q1801.03 194.022 1802.75 188.791 Q1804.46 183.56 1807.95 178.097 L1811.66 178.097 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1819.48 223.93 L1819.48 188.143 L1823.74 188.143 L1823.74 204.254 Q1823.74 207.61 1825.34 209.323 Q1826.94 211.036 1830.06 211.036 Q1833.49 211.036 1835.2 209.092 Q1836.94 207.147 1836.94 203.258 L1836.94 188.143 L1841.19 188.143 L1841.19 208.096 Q1841.19 209.485 1841.59 210.157 Q1842 210.805 1842.86 210.805 Q1843.07 210.805 1843.44 210.689 Q1843.81 210.55 1844.46 210.272 L1844.46 213.698 Q1843.51 214.231 1842.65 214.485 Q1841.82 214.74 1841.01 214.74 Q1839.41 214.74 1838.46 213.837 Q1837.51 212.934 1837.17 211.083 Q1836.01 212.911 1834.32 213.837 Q1832.65 214.74 1830.38 214.74 Q1828.02 214.74 1826.36 213.837 Q1824.71 212.934 1823.74 211.129 L1823.74 223.93 L1819.48 223.93 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1850.64 192.541 L1880.31 192.541 L1880.31 196.43 L1850.64 196.43 L1850.64 192.541 M1850.64 201.985 L1880.31 201.985 L1880.31 205.921 L1850.64 205.921 L1850.64 201.985 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1900.99 194.925 Q1897.84 194.925 1895.99 197.078 Q1894.16 199.231 1894.16 202.981 Q1894.16 206.708 1895.99 208.883 Q1897.84 211.036 1900.99 211.036 Q1904.13 211.036 1905.96 208.883 Q1907.81 206.708 1907.81 202.981 Q1907.81 199.231 1905.96 197.078 Q1904.13 194.925 1900.99 194.925 M1910.27 180.273 L1910.27 184.532 Q1908.51 183.698 1906.7 183.259 Q1904.92 182.819 1903.16 182.819 Q1898.53 182.819 1896.08 185.944 Q1893.65 189.069 1893.3 195.388 Q1894.67 193.374 1896.73 192.309 Q1898.79 191.222 1901.26 191.222 Q1906.47 191.222 1909.48 194.393 Q1912.51 197.541 1912.51 202.981 Q1912.51 208.305 1909.37 211.522 Q1906.22 214.74 1900.99 214.74 Q1894.99 214.74 1891.82 210.157 Q1888.65 205.55 1888.65 196.823 Q1888.65 188.629 1892.54 183.768 Q1896.43 178.884 1902.98 178.884 Q1904.74 178.884 1906.52 179.231 Q1908.32 179.578 1910.27 180.273 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1920.57 208.189 L1925.45 208.189 L1925.45 214.069 L1920.57 214.069 L1920.57 208.189 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1945.64 197.657 Q1942.31 197.657 1940.38 199.439 Q1938.49 201.221 1938.49 204.346 Q1938.49 207.471 1940.38 209.254 Q1942.31 211.036 1945.64 211.036 Q1948.97 211.036 1950.89 209.254 Q1952.81 207.448 1952.81 204.346 Q1952.81 201.221 1950.89 199.439 Q1948.99 197.657 1945.64 197.657 M1940.96 195.666 Q1937.95 194.925 1936.26 192.865 Q1934.6 190.805 1934.6 187.842 Q1934.6 183.698 1937.54 181.291 Q1940.5 178.884 1945.64 178.884 Q1950.8 178.884 1953.74 181.291 Q1956.68 183.698 1956.68 187.842 Q1956.68 190.805 1954.99 192.865 Q1953.32 194.925 1950.34 195.666 Q1953.72 196.453 1955.59 198.745 Q1957.49 201.036 1957.49 204.346 Q1957.49 209.37 1954.41 212.055 Q1951.36 214.74 1945.64 214.74 Q1939.92 214.74 1936.84 212.055 Q1933.79 209.37 1933.79 204.346 Q1933.79 201.036 1935.68 198.745 Q1937.58 196.453 1940.96 195.666 M1939.25 188.282 Q1939.25 190.967 1940.92 192.472 Q1942.61 193.976 1945.64 193.976 Q1948.65 193.976 1950.34 192.472 Q1952.05 190.967 1952.05 188.282 Q1952.05 185.597 1950.34 184.092 Q1948.65 182.587 1945.64 182.587 Q1942.61 182.587 1940.92 184.092 Q1939.25 185.597 1939.25 188.282 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1976.38 194.925 Q1973.23 194.925 1971.38 197.078 Q1969.55 199.231 1969.55 202.981 Q1969.55 206.708 1971.38 208.883 Q1973.23 211.036 1976.38 211.036 Q1979.53 211.036 1981.36 208.883 Q1983.21 206.708 1983.21 202.981 Q1983.21 199.231 1981.36 197.078 Q1979.53 194.925 1976.38 194.925 M1985.66 180.273 L1985.66 184.532 Q1983.9 183.698 1982.1 183.259 Q1980.31 182.819 1978.55 182.819 Q1973.93 182.819 1971.47 185.944 Q1969.04 189.069 1968.69 195.388 Q1970.06 193.374 1972.12 192.309 Q1974.18 191.222 1976.66 191.222 Q1981.86 191.222 1984.87 194.393 Q1987.91 197.541 1987.91 202.981 Q1987.91 208.305 1984.76 211.522 Q1981.61 214.74 1976.38 214.74 Q1970.38 214.74 1967.21 210.157 Q1964.04 205.55 1964.04 196.823 Q1964.04 188.629 1967.93 183.768 Q1971.82 178.884 1978.37 178.884 Q1980.13 178.884 1981.91 179.231 Q1983.72 179.578 1985.66 180.273 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M1996.45 208.189 L2001.33 208.189 L2001.33 212.17 L1997.54 219.578 L1994.55 219.578 L1996.45 212.17 L1996.45 208.189 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2035.55 191.522 Q2032.03 191.522 2030.13 194.069 Q2028.14 196.731 2028.14 201.129 Q2028.14 205.782 2030.11 208.467 Q2032.1 211.129 2035.55 211.129 Q2038.95 211.129 2040.94 208.444 Q2042.93 205.758 2042.93 201.129 Q2042.93 196.893 2040.94 194.069 Q2039.11 191.522 2035.55 191.522 M2035.55 188.143 L2049.69 188.143 L2049.69 192.402 L2044.92 192.402 Q2047.44 196.013 2047.44 201.129 Q2047.44 207.495 2044.27 211.106 Q2041.1 214.74 2035.55 214.74 Q2029.97 214.74 2026.82 211.106 Q2023.65 207.495 2023.65 201.129 Q2023.65 194.717 2026.82 191.129 Q2029.43 188.143 2035.55 188.143 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2056.1 192.541 L2085.78 192.541 L2085.78 196.43 L2056.1 196.43 L2056.1 192.541 M2056.1 201.985 L2085.78 201.985 L2085.78 205.921 L2056.1 205.921 L2056.1 201.985 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2105.87 182.587 Q2102.26 182.587 2100.43 186.152 Q2098.62 189.694 2098.62 196.823 Q2098.62 203.93 2100.43 207.495 Q2102.26 211.036 2105.87 211.036 Q2109.5 211.036 2111.31 207.495 Q2113.14 203.93 2113.14 196.823 Q2113.14 189.694 2111.31 186.152 Q2109.5 182.587 2105.87 182.587 M2105.87 178.884 Q2111.68 178.884 2114.73 183.49 Q2117.81 188.073 2117.81 196.823 Q2117.81 205.55 2114.73 210.157 Q2111.68 214.74 2105.87 214.74 Q2100.06 214.74 2096.98 210.157 Q2093.92 205.55 2093.92 196.823 Q2093.92 188.073 2096.98 183.49 Q2100.06 178.884 2105.87 178.884 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2126.03 208.189 L2130.92 208.189 L2130.92 214.069 L2126.03 214.069 L2126.03 208.189 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2155.27 195.434 Q2158.62 196.152 2160.5 198.421 Q2162.4 200.689 2162.4 204.022 Q2162.4 209.138 2158.88 211.939 Q2155.36 214.74 2148.88 214.74 Q2146.7 214.74 2144.39 214.3 Q2142.1 213.883 2139.64 213.027 L2139.64 208.513 Q2141.59 209.647 2143.9 210.226 Q2146.22 210.805 2148.74 210.805 Q2153.14 210.805 2155.43 209.069 Q2157.74 207.333 2157.74 204.022 Q2157.74 200.967 2155.59 199.254 Q2153.46 197.518 2149.64 197.518 L2145.61 197.518 L2145.61 193.675 L2149.83 193.675 Q2153.28 193.675 2155.1 192.309 Q2156.93 190.921 2156.93 188.328 Q2156.93 185.666 2155.04 184.254 Q2153.16 182.819 2149.64 182.819 Q2147.72 182.819 2145.52 183.235 Q2143.32 183.652 2140.68 184.532 L2140.68 180.365 Q2143.35 179.624 2145.66 179.254 Q2148 178.884 2150.06 178.884 Q2155.38 178.884 2158.48 181.314 Q2161.59 183.722 2161.59 187.842 Q2161.59 190.712 2159.94 192.703 Q2158.3 194.671 2155.27 195.434 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2181.26 182.587 Q2177.65 182.587 2175.82 186.152 Q2174.02 189.694 2174.02 196.823 Q2174.02 203.93 2175.82 207.495 Q2177.65 211.036 2181.26 211.036 Q2184.9 211.036 2186.7 207.495 Q2188.53 203.93 2188.53 196.823 Q2188.53 189.694 2186.7 186.152 Q2184.9 182.587 2181.26 182.587 M2181.26 178.884 Q2187.07 178.884 2190.13 183.49 Q2193.21 188.073 2193.21 196.823 Q2193.21 205.55 2190.13 210.157 Q2187.07 214.74 2181.26 214.74 Q2175.45 214.74 2172.37 210.157 Q2169.32 205.55 2169.32 196.823 Q2169.32 188.073 2172.37 183.49 Q2175.45 178.884 2181.26 178.884 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2200.24 179.509 L2222.47 179.509 L2222.47 181.499 L2209.92 214.069 L2205.04 214.069 L2216.84 183.444 L2200.24 183.444 L2200.24 179.509 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /><path clip-path="url(#clip910)" d="M2230.31 178.097 L2234.02 178.097 Q2237.49 183.56 2239.2 188.791 Q2240.94 194.022 2240.94 199.184 Q2240.94 204.37 2239.2 209.624 Q2237.49 214.879 2234.02 220.319 L2230.31 220.319 Q2233.39 215.018 2234.9 209.786 Q2236.42 204.532 2236.42 199.184 Q2236.42 193.837 2234.9 188.629 Q2233.39 183.421 2230.31 178.097 Z" fill="#000000" fill-rule="evenodd" fill-opacity="1" /></svg>


<pre class='language-julia'><code class='language-julia'># Define the model
flextrola_nvm = NVModel(cost = 72, price = 121, salvage = 50, demand=flextrola_demand)</code></pre>
<pre id='var-flextrola_nvm' class='code-output documenter-example-output'>Data of the Newsvendor Model
 * Demand distribution: LogNormal{Float64}(μ=6.754012929108157, σ=0.5545130293761911)
 * Unit cost: 72.00
 * Unit selling price: 121.00
 * Unit salvage value: 50.00
</pre>

<pre class='language-julia'><code class='language-julia'>solve(flextrola_nvm)</code></pre>
<pre id='var-hash983875' class='code-output documenter-example-output'>=====================================
Results of maximizing expected profit
 * Optimal quantity: 1129 units
 * Expected profit: 33850.63
=====================================
This is a consequence of
 * Cost of underage:  49.00
   ╚ + Price:               121.00
   ╚ - Cost:                72.00
 * Cost of overage:   22.00
   ╚ + Cost:                72.00
   ╚ - Salvage value:       50.00
 * Critical fractile: 0.69
 * Rounded to closest integer: true
-------------------------------------
Ordering the optimal quantity yields
 * Expected sales: 826.60 units
 * Expected lost sales: 173.40 units
 * Expected leftover: 302.40 units
 * Expected salvage revenue: 15119.98
-------------------------------------
</pre>


```
## References
```@raw html
<div class="markdown">

<ul>
<li><p><a href="https://github.com/frankhuettner/NewsvendorModel.jl">NewsvendorModel.jl</a></p>
</li>
<li><p>Gerard Cachon, Christian Terwiesch, <a href="http://cachon-terwiesch.net/3e/index.php">Matching Supply with Demand: An Introduction to Operations Management. McGraw-Hill &#40;2012&#41;</a>, Chapters 12 and 13.</p>
</li>
<li><p>Gerard Cachon, Christian Terwiesch, Matching Supply with Demand: An Introduction to Operations Management. McGraw-Hill &#40;<a href="https://www.mheducation.com/highered/product/">2018</a>&#41;, Chapters 14 and 15.</p>
</li>
</ul>
</div>

<!-- PlutoStaticHTML.End -->
```

