function leftover(d::DiscreteUnivariateDistribution, q)
    lower = max(minimum(d), 0) 
    upper = min(maximum(d), q) 
    return sum((q - y) * pdf(d, y) for y in lower:upper; init = 0.0)
end

function leftover(d::ContinuousUnivariateDistribution, q)
    I, _ = quadgk(y -> (q - y) * pdf(d, y), minimum(d), q)
    return I
end

# For normal distributions, we use σ * (ϕ(z) + z*Φ(z)) where z = (q - μ) / σ.
I(z) = pdf(Normal(), z) + z * cdf(Normal(), z) 
function leftover(d::Normal, q)
    z = (q - mean(d)) / std(d)
    return std(d) * I(z)
end