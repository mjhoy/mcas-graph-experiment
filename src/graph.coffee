# Set up the geo projection for Massachusetts.
projection = d3.geo.albers().origin([-71.65, 42.19]).scale(19000)
path = d3.geo.path().projection(projection)

w = 950
h = 580

window.x = d3.scale.linear().domain([0, 100]).range [20, w/4]
window.y = d3.scale.linear().domain([0, 100]).range [0, h]

subj = "ELA"
perf = "P+/A %"
year = "2010"

# Render the graph for `subj` and `perf`.
render = (subj, perf, year) ->
  d3.selectAll("circle.point")
    .transition().ease("cubic-in-out")
    .attr('r', (d) ->
      if d[year] and d[year][subj] and d[year][subj][perf]
        circle_width(+d[year][subj][perf])
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

perf_keys = null
subj_keys = null
update_info =  ->
  unless perf_keys
    perf_keys = {}
    subj_keys = {}
    $('.performance li').each (i, el) ->
      perf_keys[$(el).data('key')] = $(el).text()
    $('.subject li').each (i, el) ->
      subj_keys[ $(el).data('key') ] = $(el).text()
  data = $('circle.point.active')[0].__data__
  head = $('#info h2')
  body = $('#info .body')
  body.html('')
  if data[year] and data[year][subj] and data[year][subj][perf]
    body.text("#{data[year][subj][perf]}% #{perf_keys[perf]} in #{subj_keys[subj]} in #{year}")
  else
    body.text("No data for this entry.")
  head.text(data["denorm"]["school"])

setup_handlers = (svg) ->

  $('circle.point').click( (e) ->
    d3.selectAll('circle.point')
      .classed('active', false)
    d3.select(e.currentTarget)
      .classed('active', true)
    update_info()
  )
  

# Document ready.
jQuery ->

  $("li[data-key='#{subj}']").addClass('active')
  $("li[data-key='#{perf}']").addClass('active')
  $("li[data-key='#{year}']").addClass('active')
  $('nav .subject li').click (e) ->
    if s = $(e.currentTarget).data('key')
      $(e.currentTarget).addClass('active').siblings().removeClass('active')
      subj = s
      render(subj, perf, year)
      update_info()
  $('nav .performance li').click (e) ->
    if s = $(e.currentTarget).data('key')
      $(e.currentTarget).addClass('active').siblings().removeClass('active')
      perf = s
      render(subj, perf, year)
      update_info()
  $('nav .year li').click (e) ->
    if s = $(e.currentTarget).data('key')
      $(e.currentTarget).addClass('active').siblings().removeClass('active')
      year = s
      render(subj, perf, year)
      update_info()

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

    d3.json "../data/g10_all.json", (data) ->

      svg.selectAll("circle.point")
        .data(data)
        .enter().append("svg:circle")
        .attr('class', 'point')
        .attr('cx', (d) ->
          if d["denorm"] and d["denorm"]["geometry"]
            ll = d["denorm"]["geometry"]
            projection([ll["lng"], ll["lat"]])[0] # Longitude
          else
            -100
        )
        .attr('cy', (d) ->
          if d["denorm"] and d["denorm"]["geometry"]
            ll = d["denorm"]["geometry"]
            projection([ll["lng"], ll["lat"]])[1] # Longitude
          else
            -100
        )
        .attr('fill-opacity', (d) ->
          0.6
        )
      render(subj, perf, year)

      setup_handlers()

