---------------BOSS MENU---------------

Config = {
    Jobs = {
        ['police'] = {
            Grades = {
                [4] = true,
                [5] = true
            },
            Positions = {
                vector3(465.2098, -1009.433, 35.93106),
                vector3(1848.52, 3688.69, 39.51)
            }
        },
    }
}

function isPlayerJobBoss(jobName, jobGrade)
    return jobName and jobGrade and Config.Jobs[jobName] and Config.Jobs[jobName].Grades[jobGrade]
end

function isJobBoss(jobObj)
    return jobObj and jobObj.name and jobObj.grade and Config.Jobs[jobObj.name] and Config.Jobs[jobObj.name].Grades[jobObj.grade.level]
end
