# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class WelcomeController
  index: ->
    $("#main-form").submit (e) ->
      url = "/users/" + $("#user_id").val()
      $.ajax({
        type: "GET",
        url: url,
        data: $("#main-form").serialize(),
        success: (data) ->
          $("#btn-submit").prop("disabled", false)
          Shiiba.weed.drawCalendar data
      })
      e.preventDefault()

class QiitaWeed
  # セルの1辺のサイズ
  CELL_SIZE = 15

  # カレンダ表示のマージン
  MARGIN_LEFT = 25
  MARGIN_TOP = 15

  constructor: ->
    @dataset = null
    @color = null
    @countScale = null

  # 日付の計算
  addDays = (sourceDate, days) ->
    result = new Date(sourceDate)
    result.setDate sourceDate.getDate() + days
    return result

  # 表示する日付の範囲(過去１年間)
  rangeBegin = addDays(new Date, -365)
  rangeEnd = new Date
  dateRange = d3.time.days(rangeBegin, rangeEnd)
  monthRange = d3.time.months(rangeBegin, rangeEnd)

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

  # count数の大きさに応じたcolorを求める関数
  createColorFunc = (countScaleFunc) =>
    colorScale = d3.scale.ordinal()
                  .domain([1, 2, 3])
                  .range(["#f7fcb9","#addd8e","#31a354"])
    return (f) -> colorScale(countScaleFunc(f))

  # カレンダー描画
  drawCalendar: (dataset) ->
    @dataset = dataset
    @countScale = d3.scale.linear()
                  .domain([1, d3.max(d3.values(dataset))])
                  .rangeRound([1, 3])
                  .clamp(true)
    @color = createColorFunc(@countScale)


    # svg要素の作成
    svg = d3.select(".weed")
    svg.selectAll("*").remove()
    svg.append("g")

    # 日付のフォーマット
    format = d3.time.format("%Y-%m-%d")

    # 日毎の矩形を生成
    offset = createOffsetFunc()
    rect = svg.selectAll(".day")
              .data(dateRange)
              .enter()
              .append("rect")
                .attr("class", "day")
                .attr("width", CELL_SIZE - 1)
                .attr("height", CELL_SIZE - 1)
                .attr("x", (d) -> (d3.time.weekOfYear(d) + offset(d)) * CELL_SIZE + MARGIN_LEFT)
                .attr("y", (d) -> d.getDay() * CELL_SIZE + MARGIN_TOP)
                .attr("fill", "rgb(230,230,230)")
              .datum(format)

    # ツールチップ設定
    rect.append("title")
        .text((d) -> d)

    # 投稿のあった日のツールチップと背景色を設定
    rect.filter((d) -> dataset[d]?)
        .attr("fill", (d) => @color(dataset[d]))
        .select("title")
        .text((d) -> d + " (投稿:" + dataset[d] + "件)")

    # 曜日のラベル
    dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    svg.selectAll(".dayLabel")
       .data([0..6])
       .enter()
       .append("text")
         .attr("class", "dayLabel")
         .attr("x", 0)
         .attr("y", (d) -> d * CELL_SIZE + 11 + MARGIN_TOP)
         .attr("font-size", 11)
         .attr("fill", "gray")
         .text((d) -> dayLabels[d])
    # 月のラベル
    monthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    svg.selectAll(".monthLabel")
      .data(monthRange)
      .enter()
      .append("text")
        .attr("class", "monthLabel")
        .attr("x", (d) -> (d3.time.weekOfYear(d) + offset(d)) * CELL_SIZE + MARGIN_LEFT)
        .attr("y", 11)
        .attr("font-size", 11)
        .attr("fill", "gray")
        .text((d) -> monthLabels[d.getMonth()])

Shiiba.welcome = new WelcomeController
Shiiba.weed = new QiitaWeed
