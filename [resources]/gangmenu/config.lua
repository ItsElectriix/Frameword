---------------BOSS MENU---------------

Config = {
    Gangs = {
        ['green'] = {
            Grades = {
                [2] = true,
            },
            Positions = {
                vector3(202.64328, -810.3897, 30.988363),
                vector3(1848.52, 3688.69, 39.51)
            }
        },
        ['blue'] = {
            Grades = {
                [2] = true,
            },
            Positions = {
                vector3(465.2098, -1009.433, 35.93106),
                vector3(1848.52, 3688.69, 39.51)
            }
        },
    }
}

function isPlayerGangBoss(jobName, jobGrade)
    return jobName and jobGrade and Config.Gangs[jobName] and Config.Gangs[jobName].Grades[jobGrade]
end

function isGangBoss(jobObj)
    return jobObj and jobObj.name and jobObj.grade and Config.Gangs[jobObj.name] and Config.Gangs[jobObj.name].Grades[jobObj.grade.level]
end