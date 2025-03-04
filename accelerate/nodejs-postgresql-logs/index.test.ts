import { test, expect, jest } from '@jest/globals'
import { PrismaClient, Prisma } from '@prisma/client'
import { withAccelerate } from '@prisma/extension-accelerate'

test('accelerate logs with postgres', async () => {
  const prisma = new PrismaClient({
    log: [{ emit: 'event', level: 'query' }],
  })

  let xprisma = prisma

  if (process.env.DATAPROXY_FLAVOR === 'DP2+Extension') {
    xprisma = xprisma.$extends(withAccelerate()) as any
  }

  const onQuery = jest.fn<(event: Prisma.QueryEvent) => void>()
  prisma.$on('query', onQuery)

  await xprisma.user.findMany()

  // Sometimes there's another "SELECT 1" before the actual query we're testing for.
  const lastQueryIndex = onQuery.mock.calls.length - 1

  expect(onQuery.mock.calls[lastQueryIndex][0].query).toMatchInlineSnapshot(
    `"SELECT "public"."User"."user_id", "public"."User"."email", "public"."User"."name" FROM "public"."User" WHERE 1=1 OFFSET $1"`,
  )
})
