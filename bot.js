require('dotenv').config();

const { Client, GatewayIntentBits, Events, Collection } = require('discord.js');
const { getGrade } = require('./internal/get_grade.js');
const fs = require('node:fs');
const path = require('node:path');
const client = new Client({ intents: [GatewayIntentBits.Guilds] });

const token = process.env.DISCORD_TOKEN;
const channelId = process.env.DISCORD_ACTIVE_CHANNEL_ID;


client.commands = new Collection();

const foldersPath = path.join(__dirname, 'commands');
const commandFolders = fs.readdirSync(foldersPath);

for (const folder of commandFolders) {
	const commandsPath = path.join(foldersPath, folder);
	const commandFiles = fs.readdirSync(commandsPath).filter(file => file.endsWith('.js'));
	for (const file of commandFiles) {
		const filePath = path.join(commandsPath, file);
		const command = require(filePath);
		if ('data' in command && 'execute' in command) {
			client.commands.set(command.data.name, command);
		} else {
			console.log(`[${new Date().toLocaleString()}] [WARNING] The command at ${filePath} is missing a required "data" or "execute" property.`);
		}
	}
}

const CourseManager = require('./internal/CourseManager.js');
CourseManager.readCache();

client.once(Events.ClientReady, c => {
	console.log(`[${new Date().toLocaleString()}] Ready! Logged in as ${c.user.tag}`);
    watchForGrades();
});

client.on(Events.InteractionCreate, async interaction => {
    if (!interaction.isCommand() || interaction.channelId !== channelId) {
        return;
    }

    const command = client.commands.get(interaction.commandName);

    if (!command) {
        return;
    }

    try {
        await command.execute(interaction);
    } catch (error) {
        console.error(error);
        await interaction.editReply({ content: 'There was an error while executing this command!', ephemeral: true });
    }
});

client.login(token);

async function watchForGrades() {
    const handleShutdown = () => {
        console.log('\nTerminating the application...');
        process.exit(0);
    };

    process.on('SIGINT', handleShutdown);

    // Schedule grade checking every 5 minutes using setInterval
    setInterval(async () => {
        try {
            if (CourseManager.courseCodes.length > 0) {
                const gradeMap = await getGrade(CourseManager.courseCodes);

                if (Object.keys(gradeMap).length > 0) {
                    for (const [course, grade] of Object.entries(gradeMap)) {
                        console.log(`[${new Date().toLocaleString()}] New grade found for ${course}`);

                        const channel = await client.channels.fetch(channelId);
                        await channel.send(`New grade found for ${course} - ${grade}`);

                        const success = CourseManager.removeCourse(course);
                        if (!success) {
                            console.log(`[${new Date().toLocaleString()}] Failed to remove ${course} from the course codes list`);
                        }
                    }
                }
            }
        } catch (e) {
            console.error(`Unhandled exception occurred: ${e.message}`);
        }

        console.log(`[${new Date().toLocaleString()}] Waiting...`);
    }, 300000); // 300000 milliseconds = 5 minutes
}
