# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class WelcomeController
  index: ->
    $("#main-form").submit (e) ->
      url = "/users/" + $("#user_id").val()
      console.log("url:" + url)
      $.ajax({
        type: "GET",
        url: url,
        data: $("#main-form").serialize(),
        success: (data) ->
          $("#btn-submit").prop("disabled", false)
          console.log data
          drawCalendar.call @, data
      })
      e.preventDefault()

  CELL_SIZE = 15

  # 日付の計算
  addDays = (sourceDate, days) ->
    result = new Date(sourceDate)
    result.setDate sourceDate.getDate() + days
    return result

  # 表示する日付の範囲(過去１年間)
  rangeBegin = addDays(new Date, -365)
  rangeEnd = new Date
  dateRange = d3.time.days(rangeBegin, rangeEnd)

  # カレンダのオフセット値を算出する関数
  createOffsetFunc = ->
    firstYearOffset = d3.time.weekOfYear(rangeBegin) * -1
    bounderyDate = d3.time.years(rangeBegin, rangeEnd)[0]
    lastDayOfFirstYear = addDays(bounderyDate, -1)
    lastWeekOfFirstYear = d3.time.weekOfYear(lastDayOfFirstYear)
    lastYearOffset = d3.time.weekOfYear(lastDayOfFirstYear) + firstYearOffset

    return (sourceDate) ->
      if sourceDate.getFullYear() == rangeBegin.getFullYear()
        return firstYearOffset
      return lastYearOffset

  offset = createOffsetFunc()

  # count数の大きさに応じたcolorを求める関数
  createColorFunc = (dataset) ->
    _countScale = d3.scale.linear()
                  .domain([1, d3.max(d3.values(dataset))])
                  .rangeRound([0, 4])
                  .clamp(true)
    _colorScale = d3.scale.ordinal()
                  .domain([1, 2, 3, 4, 5])
                  .range(["#ffffcc","#c2e699","#78c679","#31a354","#006837"])
    return (f) -> _colorScale(_countScale(f))

  # カレンダー描画
  drawCalendar = (dataset) ->
    color = createColorFunc(dataset)

    # svg要素の作成
    svg = d3.select(".weed")
    svg.selectAll("*").remove()
    svg.append("g")

    # 日付のフォーマット
    format = d3.time.format("%Y-%m-%d")

    # 日毎の矩形を生成
    rect = svg.selectAll(".day")
              .data(dateRange)
              .enter()
              .append("rect")
                .attr("class", "day")
                .attr("width", CELL_SIZE - 1)
                .attr("height", CELL_SIZE - 1)
                .attr("x", (d) -> (d3.time.weekOfYear(d) + offset(d)) * CELL_SIZE)
                .attr("y", (d) -> d.getDay() * CELL_SIZE)
                .attr("fill", "rgb(230,230,230)")
              .datum(format)

    # ツールチップ設定
    rect.append("title")
        .text((d) -> d)

    # 投稿のあった日のツールチップと背景色を設定
    rect.filter((d) -> dataset[d]?)
        .attr("fill", (d) -> color(dataset[d]))
        .select("title")
        .text((d) -> d + " (投稿:" + dataset[d] + "件)")

Shiiba.welcome = new WelcomeController

