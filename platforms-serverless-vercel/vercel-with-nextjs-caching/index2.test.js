const fetch = require('node-fetch')
const fs = require('fs')

function getDeploymentURL() {
  const data = fs.readFileSync('./deployment-url.txt', { encoding: 'utf8' })
  return data.trim()
}

const endpoint = getDeploymentURL()

const DELAY = 5_000
let backOff = -DELAY

test('simple query', async () => {
  await new Promise((r) => setTimeout(r, (backOff += DELAY)))

  const r = await fetch(endpoint + '/api', {
    headers: {
      'user-agent': 'ecosystem-tests',
    },
  })

  const data = await r.json()
  expect(data).toMatchObject({
    value: true,
  })
})

jest.retryTimes(10, { logErrorsBeforeRetry: true })
jest.setTimeout(10 * DELAY)
