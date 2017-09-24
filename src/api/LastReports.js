export default [{
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}, {
  id: 5146,
  time: 1500650440,
  arriveAt: 1500650445,
  data: 3156.00
}]

import moment from 'moment'
import { secondsToMillis } from '../utils/datetime'

/*
  required API request:
    ?period=48hours

  Merge two days records together by order, and limit the first 50(for example) records

  Return a collection of records:
  {
    id: node_id,
    time: timestamp,
    data: total,
  }
 */
export function parseLastReports (powerDetailList) {
  const nodeId = powerDetailList.length > 0 ? powerDetailList[0]['node_id'] : ''

  const entryRecordToOption = (entry) => {
    return {
      id: nodeId,
      time: moment(secondsToMillis(entry.time)).format('YYYY-MM-DD HH:mm'),
      data: entry.total
    }
  }

  const records = powerDetailList.reduce((daySum, dayRecord) => {
    return daySum.concat(dayRecord ? dayRecord.detail.map(entryRecordToOption) : [])
  }, [])

  // force sort once, by time descending
  records.sort((x1, x2) => (x2.time - x1.time))

  return records.slice(0, 50)
}
