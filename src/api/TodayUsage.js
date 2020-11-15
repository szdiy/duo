// 注： 这里的电量应该是用电量（delta）而非读数
const DEFAULT_DATA = [{
  title: '今日电量',
  total: '0.00',
  sub: 'Updated: 00:00',
  usage: '0.00'
}, {
  title: '昨日电量',
  total: '0.00',
  sub: 'Updated: 00:00',
  usage: '0.00'
}, {
  title: '本月电量',
  total: '0.00',
  sub: 'Updated: 00:00',
  usage: '0.00'
}, {
  title: '上月电量',
  total: '0.00',
  sub: 'Updated: 00:00',
  usage: '0.00'
}]

export default DEFAULT_DATA

import moment from 'moment'
import { secondsToMillis, createPeriodChecker } from '../utils/datetime'
/*
  Required API request:
    ?preiod=3months
    repsonse = array of simple entries:
        {
          date: 'YYYY-MM-DD',
          node_id: '001',
          simple: {
            total: 12345,
            time: 1234567890
          }
        }

  Return a report of summary:
    (template of DEFAULT_DATA)
 */
export function parseOverviewReport (response) {
  // 创建一个默认数据的副本
  const usageReport = DEFAULT_DATA.map((defaultUsage) => Object.assign({}, defaultUsage))

  // 获取昨日和今日的电量读数
  const today = moment().startOf('day')
  const yesterday = moment().subtract(1, 'd').startOf('day')
  const todayQuery = createDatePeriodBoundaryQuery(today, today)
  const yesterdayQuery = createDatePeriodBoundaryQuery(yesterday, yesterday)

  return usageReport
}

// 将response的simple entry转换成TodayUsage要用的显示内容
function parsePeriodToUsageDisplay (period, withDate = false) {
  let total = Number(0).toFixed(2)
  let dateStr = 'N/A'

  if (period.start && period.end) {
    const entryDate = moment(secondsToMillis(period.end.simple.time))
    dateStr = entryDate.format(withDate ? 'YYYY-MM-DD HH:mm' : 'HH:mm')

    total = Number(period.end.simple.total - period.start.simple.total).toFixed(2)
  }

  return {
    total,
    sub: `Updated: ${dateStr}`
  }
}

/*
  根据开始日期和结束日期生成一个查询器，当给出一个日期的列表数据时，能找出用于算这个区间差值的开始和结束元素。

  例如：
    1. 算当天的电量： 返回{ start: 昨日记录，end: 今日记录 }
    2. 算当月的电量： 返回{ start: 上月最后一日的记录, end: 今月最后一日的记录 }

  如果边界记录不存在的话，会返回落在这个日期区间内最接近边界的记录
 */
function createDatePeriodBoundaryQuery (startDate, endDate) {
  const lastBeforeStart = startDate.subtract(1, 'day')
  return (entries) => {

  }
}
