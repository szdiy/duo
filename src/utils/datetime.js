
export const secondsToMillis = (seconds) => {
  return seconds * 1000
}

export const milliesToSeconds = (millis) => {
  return millis / 1000
}

export const createPeriodChecker = (startMoment, endMoment) => {
  const startMillis = startMoment.valueOf()
  const endMillis = endMoment.valueOf()

  return (millis) => {
    return millis >= startMillis && millis <= endMillis
  }
}
