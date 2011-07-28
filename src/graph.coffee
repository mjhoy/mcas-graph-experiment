# Set up the geo projection for Massachusetts.
projection = d3.geo.albers().origin([-71.65, 42.19]).scale(19000)
path = d3.geo.path().projection(projection)

w = 950
h = 580

# Document ready.
jQuery ->

  svg = d3.select('#chart-1')
    .append("svg:svg")
    .attr("width", w)
    .attr("height", h)

  # Graph the state.
  d3.json "../data/mass-geo.json", (json) ->
    svg.selectAll("path")
      .data(json.features)
      .enter().append("svg:path")
      .attr("d", path)
      .attr("class", "state")
