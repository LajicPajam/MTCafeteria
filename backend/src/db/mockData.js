const bcrypt = require('bcryptjs');
const { Roles } = require('../config/roles');

const today = new Date().toISOString().slice(0, 10);
const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

const roles = [
  { id: 1, name: Roles.EMPLOYEE },
  { id: 2, name: Roles.LEAD_TRAINER },
  { id: 3, name: Roles.SUPERVISOR },
  { id: 4, name: Roles.STUDENT_MANAGER },
];

const users = [
  { id: 1, email: 'employee@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 1, points: 14 },
  { id: 2, email: 'trainer@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 2, points: 22 },
  { id: 3, email: 'supervisor@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 3, points: 30 },
  { id: 4, email: 'manager@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 4, points: 45 },
  { id: 5, email: 'employee2@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 1, points: 9 },
  { id: 6, email: 'employee3@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 1, points: 11 },
  { id: 7, email: 'employee4@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 1, points: 6 },
];

const announcements = [
  {
    id: 1,
    type: 'Announcement',
    title: 'Welcome to this Week',
    content: 'Please review shift boards before your first shift.',
    startDate: today,
    endDate: tomorrow,
    createdBy: 4,
  },
  {
    id: 2,
    type: 'Reminder',
    title: 'Hairnet Reminder',
    content: 'Hairnets are required in all kitchen and line areas.',
    startDate: today,
    endDate: tomorrow,
    createdBy: 4,
  },
  {
    id: 3,
    type: 'Special Event',
    title: 'VIP Dinner Service',
    content: 'Special dinner setup starts 30 minutes earlier on Friday.',
    startDate: tomorrow,
    endDate: tomorrow,
    createdBy: 4,
  },
];

const trainings = [
  { id: 1, title: 'Service Tone', content: 'Greet guests promptly and keep lines moving.', assignedDate: today },
  { id: 2, title: 'Sanitation Focus', content: 'Wipe shared surfaces every 20 minutes.', assignedDate: tomorrow },
];

const meals = ['Breakfast', 'Lunch', 'Dinner'];

const shifts = meals.map((meal, index) => ({
  id: index + 1,
  shiftType: 'Line Shift',
  mealType: meal,
  name: `${meal} Line Shift`,
}));

const jobDefinitions = [
  {
    name: 'Sack Cashier',
    meals: ['Breakfast', 'Lunch'],
    phases: {
      Setup: {
        Breakfast: [
          'Put out oatmeal',
          'Put out oatmeal cups and lids',
          'Turn on cooler lights',
          'Put out donuts',
          'Put out donut utensils',
          'Unlock door when doors open',
          'Flip sign to "Open"',
          'Set up and sign into register',
        ],
        Lunch: [
          'Put out soups',
          'Ensure sandwiches are available (not displayed)',
          'Put out cookies',
          'Put out chips',
          'Ensure salads are available',
          'Turn on cooler lights',
          'Unlock door when doors open',
          'Flip sign to "Open"',
          'Set up and sign into register',
        ],
      },
      'During Shift': {
        Breakfast: [
          'Ensure missionaries swipe cards',
          'Keep count of missionaries who do not swipe',
          'Ring up senior missionaries',
          'Communicate with sack runner when items run out',
        ],
        Lunch: [
          'Ensure missionaries swipe cards',
          'Keep count of missionaries who do not swipe',
          'Ring up senior missionaries',
          'Communicate with sack runner when items run out',
        ],
      },
      Cleanup: {
        Breakfast: [
          'Flip sign to "Closed"',
          'Lock door',
          'Log out of register',
          'Turn off cooler lights',
          'Restock drinks',
          'Put away donuts',
          'Put away oatmeal',
          'Wipe counters',
          'Vacuum area',
        ],
        Lunch: [
          'Flip sign to "Closed"',
          'Lock door',
          'Log out of register',
          'Turn off cooler lights',
          'Restock drinks',
          'Restock sandwiches',
          'Restock salads',
          'Wipe counters',
          'Vacuum area',
        ],
      },
    },
  },
  {
    name: 'Sack Runner',
    meals: ['Breakfast', 'Lunch'],
    phases: {
      Setup: ['Assist sack cashier with setup tasks'],
      'During Shift': ['Restock items from sack room as needed', 'Coordinate with sack cashier'],
      Cleanup: ['Assist sack cashier with cleanup tasks'],
    },
  },
  {
    name: 'Salads',
    meals: ['Breakfast', 'Lunch'],
    phases: {
      Setup: {
        Breakfast: [
          'Put out fruit and breakfast salad items',
          'Ensure plates are stocked',
        ],
        Lunch: [
          'Put out salad ingredients',
          'Put out tortillas',
          'Set up deli bar',
          'Ensure plates are stocked',
        ],
      },
      'During Shift': {
        Breakfast: [
          'Keep salad bar stocked',
          'Ensure plates remain stocked',
          'Keep oatmeal, grits, or similar items stocked and warm',
        ],
        Lunch: [
          'Keep salad bar stocked',
          'Ensure plates remain stocked',
        ],
      },
      Cleanup: {
        Breakfast: [
          'Wipe all surfaces',
          'Put away breakfast items',
          'Clean oatmeal or grits containers',
          'Sweep area',
          'Mop if necessary',
        ],
        Lunch: [
          'Wipe all surfaces',
          'Put away salad items',
          'Sweep area',
          'Mop if necessary',
        ],
      },
    },
  },
  {
    name: 'Paninis',
    meals: ['Lunch', 'Dinner'],
    phases: {
      Setup: ['Turn on panini machines'],
      'During Shift': [
        'Prepare paninis',
        'Press paninis in machines',
        'Cut paninis',
        'Put paninis out for service',
      ],
      Cleanup: [
        'Turn off machines',
        'Clean machines and work surfaces',
        'Put away tools and supplies',
      ],
    },
  },
  {
    name: 'Ice Cream',
    meals: ['Lunch', 'Dinner'],
    phases: {
      Setup: ['Get ice cream', 'Get scoops', 'Get bowls', 'Get water as needed'],
      'During Shift': ['Serve ice cream'],
      Cleanup: ['Put away ice cream', 'Clean scoops and bowls', 'Clean serving area'],
    },
  },
  {
    name: 'Condiments Prep',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: ['Ensure condiment cart is full', 'Assist condiments host with setup'],
      'During Shift': [
        'Keep condiments stocked',
        'Prepare condiments for next meal',
        'If dinner: prepare condiments for breakfast bar next day',
      ],
      Cleanup: ['Assist condiments host with cleanup', 'Clean prep area', 'Put away condiment cart and supplies'],
    },
  },
  {
    name: 'Condiments Host',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: ['Same tasks as breakfast condiments host setup'],
      'During Shift': ['Same tasks as breakfast condiments host during shift'],
      Cleanup: ['Same tasks as breakfast condiments host cleanup'],
    },
  },
  {
    name: 'Line Runner',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Fill wells with water',
        'Turn on heat',
        'Turn on heating elements',
        'Put food out in correct order',
        'Get utensils',
        'Prepare plate stacks',
      ],
      'During Shift': [
        'Keep food stocked',
        'Communicate with chefs as needed',
        'Put plates out 10 at a time',
        'Keep track of plate counts',
      ],
      Cleanup: [
        'Turn off heat',
        'Remove water from wells',
        'Empty buckets',
        'Turn off heating elements',
        'Wipe down all surfaces',
      ],
    },
  },
  {
    name: 'Beverages',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: ['Ensure all beverages are stocked', 'Turn on beverage machines'],
      'During Shift': [
        'Restock cups',
        'Check bib room for soda stock',
        'Ensure sodas are stocked',
        'Ensure juices are stocked',
        'Ensure all beverage stations remain stocked',
      ],
      Cleanup: [
        'Wipe down surfaces',
        'Rinse troughs',
        'Turn off all machines',
        'Wipe down machines',
        'Refill ice',
        'Put ice into machines for lines 1 and 2',
      ],
    },
  },
  {
    name: 'Senior Cash',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: ['Sign into register', 'Verify register is ready'],
      'During Shift': ['Ring up senior missionaries'],
      Cleanup: [
        'Restock napkins at tables',
        'Restock salt and pepper shakers',
        'Write next meal on whiteboard on doors',
      ],
    },
  },
  {
    name: 'Junior Cash',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: ['Sign into register'],
      'During Shift': [
        'Ensure missionaries swipe cards',
        'Keep count of missionaries without cards',
      ],
      Cleanup: ['Same cleanup tasks as Senior Cash'],
    },
  },
  {
    name: 'Desserts',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Put out desserts',
        'Breakfast: donuts',
        'Lunch/Dinner: cookies or assigned desserts',
        'Put out plates',
        'Put out utensils',
      ],
      'During Shift': ['Keep desserts stocked', 'Keep utensils stocked'],
      Cleanup: ['Put away desserts', 'Clean counters', 'Sweep area', 'Wipe down surfaces'],
    },
  },
];

const jobs = [];
let jobIdCounter = 1;
for (const shift of shifts) {
  for (const definition of jobDefinitions) {
    if (!definition.meals.includes(shift.mealType)) continue;
    jobs.push({
      id: jobIdCounter,
      shiftId: shift.id,
      name: definition.name,
    });
    jobIdCounter += 1;
  }
}

const tasks = [];
let taskIdCounter = 1;

function addTask(jobId, phase, description, requiresCheckoff = true) {
  tasks.push({
    id: taskIdCounter,
    jobId,
    phase,
    description,
    requiresCheckoff,
  });
  taskIdCounter += 1;
}

for (const job of jobs) {
  const shift = shifts.find((s) => s.id === job.shiftId);
  const definition = jobDefinitions.find((d) => d.name === job.name);
  if (!shift || !definition) continue;

  for (const phase of ['Setup', 'During Shift', 'Cleanup']) {
    const phaseDefinition = definition.phases[phase];
    const phaseTasks = Array.isArray(phaseDefinition)
      ? phaseDefinition
      : (phaseDefinition[shift.mealType] || []);

    for (const taskText of phaseTasks) {
      addTask(job.id, phase, taskText, phase !== 'During Shift');
    }
  }
}

const taskProgress = [
  { userId: 1, taskId: 1, completed: true },
  { userId: 1, taskId: 2, completed: false },
  { userId: 2, taskId: 1, completed: true },
];

const supervisorJobChecks = [
  { mealType: 'Breakfast', jobId: 1, checked: true },
  { mealType: 'Breakfast', jobId: 2, checked: false },
];

const supervisorTaskChecks = [
  { mealType: 'Breakfast', jobId: 1, taskId: 1, checked: true },
  { mealType: 'Breakfast', jobId: 1, taskId: 2, checked: false },
];

const trainerAssignments = [];
const traineeIds = [1, 5, 6, 7];
for (const meal of meals) {
  const shift = shifts.find((s) => s.mealType === meal);
  if (!shift) continue;

  const mealJobs = jobs.filter((j) => j.shiftId === shift.id);
  for (let i = 0; i < mealJobs.length; i += 1) {
    const traineeUserId = traineeIds[i % traineeIds.length];
    trainerAssignments.push({
      trainerUserId: 2,
      mealType: meal,
      traineeUserId,
      jobName: mealJobs[i].name,
    });
  }
}

module.exports = {
  roles,
  users,
  announcements,
  trainings,
  shifts,
  jobs,
  tasks,
  taskProgress,
  supervisorJobChecks,
  supervisorTaskChecks,
  trainerAssignments,
  meals,
};
