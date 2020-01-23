const { PrismaClient } = require('@prisma/client')

const photon = new PrismaClient()

exports.handler = async function(event, context, callback) {
  await client.user.deleteMany({})
  await client.post.deleteMany({})

  const createUser = await photon.user.create({
    data: {
      email: 'alice@prisma.io',
      name: 'Alice',
    },
  })

  const updateUser = await photon.user.update({
    where: {
      id: createUser.id,
    },
    data: {
      email: 'bob@prisma.io',
      name: 'Bob',
    },
  })

  const users = await photon.user.findOne({
    where: {
      id: createUser.id,
    },
  })

  const deleteManyUsers = await photon.user.deleteMany()

  return {
    statusCode: 200,
    body: JSON.stringify({
      createUser,
      updateUser,
      users,
      deleteManyUsers,
    }),
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  }
}
