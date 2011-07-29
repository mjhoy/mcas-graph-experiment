# Set up the geo projection for Massachusetts.
projection = d3.geo.albers().origin([-71.65, 42.19]).scale(19000)
path = d3.geo.path().projection(projection)

w = 950
h = 580

window.x = d3.scale.linear().domain([0, 100]).range [20, w/4]
window.y = d3.scale.linear().domain([0, 100]).range [0, h]

subj = "ELA"
perf = "P+/A %"

# Render the graph for `subj` and `perf`.
render = (subj, perf) ->
  d3.selectAll("circle.point")
    .transition().ease("cubic-in-out")
    .attr('r', (d) ->
      if d[subj]
        circle_width(+d[subj][perf])
      else
        0
    )

circle_width = (d) ->
  (Math.sqrt(d)/Math.PI) * 2

setup_keys = (svg) ->
  svg.selectAll("circle.key")
    .data(d3.range(0, 100, 20))
    .enter().append("svg:circle")
    .attr('class', 'key')
    .attr('cx', (d) -> x(100 - d))
    .attr('cy', (d) -> y(70))
    .attr('r', circle_width)
    .attr('fill', '#666')
  svg.selectAll("line.key")
    .data( [20, 80] )
    .enter().append("svg:line")
    .attr('class', 'key')
    .attr('x1', (d) -> Math.floor(x(d)) + 0.5)
    .attr('x2', (d) -> Math.floor(x(d)) + 0.5)
    .attr('y1', y(73) )
    .attr('y2', y(76) )
  svg.selectAll("text.key")
    .data( [ [20, "100%"], [80, "20%"] ] )
    .enter().append("svg:text")
    .attr('class', 'key')
    .attr('x', (d) -> x(d[0] - 5))
    .attr('y', (d) -> y(79))
    .text( (d) -> d[1] )

# Document ready.
jQuery ->

  $("li[data-key='#{subj}']").addClass('active')
  $("li[data-key='#{perf}']").addClass('active')
  $('nav .subject li').click (e) ->
    if s = $(e.currentTarget).data('key')
      $(e.currentTarget).addClass('active').siblings().removeClass('active')
      subj = s
      render(subj, perf)
  $('nav .performance li').click (e) ->
    if s = $(e.currentTarget).data('key')
      $(e.currentTarget).addClass('active').siblings().removeClass('active')
      perf = s
      render(subj, perf)

  svg = d3.select('#chart-1')
    .append("svg:svg")
    .attr("width", w)
    .attr("height", h)

  setup_keys(svg)

  # Graph the state.
  d3.json "../data/mass-geo.json", (json) ->
    svg.selectAll("path")
      .data(json.features)
      .enter().append("svg:path")
      .attr("d", path)
      .attr("class", "state")

  d3.json "../data/mcas_agg.json", (data) ->

    svg.selectAll("circle.point")
      .data(data)
      .enter().append("svg:circle")
      .attr('class', 'point')
      .attr('cx', (d) ->
        ll = d["denorm"]["geometry"]
        projection([ll["lng"], ll["lat"]])[0] # Longitude
      )
      .attr('cy', (d) ->
        ll = d["denorm"]["geometry"]
        projection([ll["lng"], ll["lat"]])[1] # Latitude
      )
      .attr('fill-opacity', (d) ->
        0.6
      )
    render(subj, perf)

