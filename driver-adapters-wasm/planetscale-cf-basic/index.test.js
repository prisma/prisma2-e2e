// @ts-check
const { test, expect } = require('@jest/globals')
const { dependencies } = require('./package.json')
const fetch = require('node-fetch').default

jest.setTimeout(30_000)

test('prisma version and output', async () => {
  const response = await fetch(process.env.DEPLOYMENT_URL + '/', {
    headers: {
      'user-agent': 'ecosystem-tests',
    },
  })
  const { regResult, itxResult } = await response.json()

  expect(regResult).toEqual(itxResult)
  expect(regResult.prismaVersion).toMatch(dependencies['@prisma/client'])
  expect(regResult.deleteMany.count).toBe(0)
  expect(regResult.create).toMatchInlineSnapshot(`
{
  "age": 27,
  "email": "test-1@prisma.io",
  "name": "Test 1",
}
`)
  expect(regResult.createMany.count).toBe(2)
  expect(regResult.findMany).toMatchInlineSnapshot(`
[
  {
    "age": 27,
    "email": "test-1@prisma.io",
    "name": "Test 1",
  },
  {
    "age": 29,
    "email": "test-2@prisma.io",
    "name": "Test 2",
  },
  {
    "age": 29,
    "email": "test-3@prisma.io",
    "name": "Test 3",
  },
]
`)
  expect(regResult.findUnique).toMatchInlineSnapshot(`
{
  "age": 27,
  "email": "test-1@prisma.io",
  "name": "Test 1",
}
`)
  expect(regResult.update).toMatchInlineSnapshot(`
{
  "age": 26,
  "email": "test-1@prisma.io",
  "name": "Test 1",
}
`)
  expect(regResult.updateMany.count).toBe(1)
  expect(regResult.findFirst).toMatchInlineSnapshot(`
{
  "age": 27,
  "email": "test-1@prisma.io",
  "name": "Test 1",
}
`)
  expect(regResult.delete).toMatchInlineSnapshot(`
{
  "age": 27,
  "email": "test-1@prisma.io",
  "name": "Test 1",
}
`)
  expect(regResult.count).toBe(2)
  expect(regResult.aggregate).toMatchInlineSnapshot(`
{
  "age": 29,
}
`)
  expect(regResult.groupBy).toMatchInlineSnapshot(`
[
  {
    "_count": {
      "age": 2,
    },
    "age": 29,
  },
]
`)
  expect(regResult.findFirstOrThrow).toMatchInlineSnapshot(`
{
  "age": 29,
  "email": "test-2@prisma.io",
  "name": "Test 2",
}
`)
  expect(regResult.findUniqueOrThrow).toMatchInlineSnapshot(`
{
  "age": 29,
  "email": "test-2@prisma.io",
  "name": "Test 2",
}
`)
  // Skipping this because of too many sub-requests (limit is 50 per fetch call)

  //   expect(regResult.upsert).toMatchInlineSnapshot(`
  // {
  //   "age": 30,
  //   "email": "test-upsert@prisma.io",
  //   "name": "Test upsert",
  // }
  // `)
})
