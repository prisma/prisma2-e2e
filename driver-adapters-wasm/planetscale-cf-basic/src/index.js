import { Prisma, PrismaClient } from '@prisma/client'
import { Client } from '@planetscale/database'
import { PrismaPlanetScale } from '@prisma/adapter-planetscale'

export default {
  async fetch(request, env, ctx) {
    const client = new Client({
      url: env.DATABASE_URL_PLANETSCALE,
      // taken from cloudflare's docs https://developers.cloudflare.com/workers/databases/native-integrations/planetscale/#:~:text=fetch%3A%20(,init)%3B
      fetch(url, init) {
        delete init['cache']
        return fetch(url, init)
      },
    })
    const adapter = new PrismaPlanetScale(client)
    const prisma = new PrismaClient({ adapter })

    const getResult = async (prisma) => {
      const result = {
        prismaVersion: Prisma.prismaVersion.client,
        deleteMany: await prisma.user.deleteMany().then(() => ({ count: 0 })),
        create: await prisma.user.create({
          data: {
            email: `test-1@prisma.io`,
            age: 27,
            name: 'Test 1',
          },
          select: {
            email: true,
            age: true,
            name: true,
          },
        }),
        createMany: await prisma.user.createMany({
          data: [
            {
              email: `test-2@prisma.io`,
              age: 29,
              name: 'Test 2',
            },
            {
              email: `test-3@prisma.io`,
              age: 29,
              name: 'Test 3',
            },
          ],
        }),
        findMany: await prisma.user.findMany({
          select: {
            email: true,
            age: true,
            name: true,
          },
          orderBy: {
            email: 'asc',
          },
        }),
        findUnique: await prisma.user.findUnique({
          where: {
            email: 'test-1@prisma.io',
          },
          select: {
            email: true,
            age: true,
            name: true,
          },
        }),
        update: await prisma.user.update({
          where: {
            email: 'test-1@prisma.io',
          },
          data: {
            age: 26,
          },
          select: {
            email: true,
            age: true,
            name: true,
          },
        }),
        updateMany: await prisma.user.updateMany({
          where: {
            age: 26,
          },
          data: {
            age: 27,
          },
        }),
        findFirst: await prisma.user.findFirst({
          where: {
            age: 27,
          },
          select: {
            email: true,
            age: true,
            name: true,
          },
        }),
        delete: await prisma.user.delete({
          where: {
            email: 'test-1@prisma.io',
          },
          select: {
            email: true,
            age: true,
            name: true,
          },
        }),
        count: await prisma.user.count(),
        aggregate: await prisma.user
          .aggregate({
            _avg: {
              age: true,
            },
          })
          .then(({ _avg }) => ({ age: Math.trunc(_avg?.age ?? 0) })),
        groupBy: await prisma.user.groupBy({
          by: ['age'],
          _count: {
            age: true,
          },
          orderBy: {
            _count: {
              age: 'asc',
            },
          },
        }),
        findFirstOrThrow: await prisma.user.findFirstOrThrow({
          select: {
            age: true,
            email: true,
            name: true,
          },
          orderBy: {
            name: 'asc',
          },
        }),
        findUniqueOrThrow: await prisma.user.findUniqueOrThrow({
          where: {
            email: 'test-2@prisma.io',
          },
          select: {
            age: true,
            email: true,
            name: true,
          },
        }),
        // Skipping this because of too many sub-requests (limit is 50 per fetch call)

        // upsert: await prisma.user.upsert({
        //   where: {
        //     email: 'test-upsert@prisma.io',
        //   },
        //   create: {
        //     email: 'test-upsert@prisma.io',
        //     age: 30,
        //     name: 'Test upsert',
        //   },
        //   update: {},
        //   select: {
        //     email: true,
        //     age: true,
        //     name: true,
        //   },
        // }),
      }

      // sort results by email to make the order deterministic
      result.findMany = result.findMany.sort((a, b) => (a.email > b.email ? 1 : -1))

      return result
    }

    const regResult = await getResult(prisma).catch((error) => ({ error_in_regResult: error.message }))
    const itxResult = await prisma.$transaction(getResult).catch((error) => ({ error_in_itxResult: error.message }))
    const result = JSON.stringify({ itxResult, regResult })

    return new Response(result)
  },
}
