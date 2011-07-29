# Set up the geo projection for Massachusetts.
projection = d3.geo.albers().origin([-71.65, 42.19]).scale(19000)
path = d3.geo.path().projection(projection)

w = 950
h = 580

subj = "ELA"
perf = "P+/A %"

# Render the graph for `subj` and `perf`.
render = (subj, perf) ->
  d3.selectAll("circle.point")
    .transition().ease("cubic-in-out")
    .attr('r', (d) ->
      if d[subj]
        +d[subj][perf] / 5
      else
        0
    )

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
