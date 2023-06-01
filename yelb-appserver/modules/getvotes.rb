require_relative 'restaurantsdbread'
require_relative 'restaurantsdbupdate'

def getvotes()
        strata = restaurantsdbread("strata")
        prisma = restaurantsdbread("prisma")
        everything = restaurantsdbread("everything")
        cortex = restaurantsdbread("cortex")
        votes = '[{"name": "strata", "value": ' + strata + '},' + '{"name": "everything", "value": ' + everything + '},' + '{"name": "prisma", "value": '  + prisma + '}, ' + '{"name": "cortex", "value": '  + cortex + '}]'
        return votes
end