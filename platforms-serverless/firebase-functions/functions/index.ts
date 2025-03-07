import { PrismaClient, Prisma } from '@prisma/client'
import * as functions from 'firebase-functions'
import { defineSecret } from 'firebase-functions/params'

// Read from config store and set as env variable
const prismaDbUrl = defineSecret('PRISMA_DB')

const __FIREBASE_FUNCTION_NAME__ = functions.https.onRequest({ secrets: [prismaDbUrl.name] }, async (req, res) => {
  process.env.DATABASE_URL = prismaDbUrl.value()

  const client = new PrismaClient({
    log: ['info', 'query', 'warn'],
  })

  const fs = require('fs')
  const path = require('path')
  const files = fs.readdirSync(path.dirname(require.resolve('.prisma/client')))

  await client.user.deleteMany({})
  const id = '12345'

  const createUser = await client.user.create({
    data: {
      id,
      email: 'alice@prisma.io',
      name: 'Alice',
    },
  })

  const updateUser = await client.user.update({
    where: {
      id: createUser.id,
    },
    data: {
      email: 'bob@prisma.io',
      name: 'Bob',
    },
  })

  const users = await client.user.findUnique({
    where: {
      id: createUser.id,
    },
  })

  const deleteManyUsers = await client.user.deleteMany({})

  res.status(200).send({
    version: Prisma.prismaVersion.client,
    createUser,
    updateUser,
    users,
    deleteManyUsers,
    files,
  })
})

export { __FIREBASE_FUNCTION_NAME__ }
