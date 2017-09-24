const PlaceHolder = require('../assets/1px.gif')
export default [{
  img: PlaceHolder,
  title: '今日电量',
  sub: 'Updated: 16:35'
}, {
  img: PlaceHolder,
  title: '昨日电量',
  sub: 'Updated: 16:35'
}, {
  img: PlaceHolder,
  title: '本月电量',
  sub: 'Updated: 16:35'
}, {
  img: PlaceHolder,
  title: '上月电量',
  sub: 'Updated: 16:35'
}]

/*
  Required API request:
    ?preiod=2months

  Return a report of summary:
  // ...
 */
export function parseOverviewReport (response) {
  return []
}
