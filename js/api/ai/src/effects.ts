
import OpenAI from 'openai';
import { MessageContentText } from 'openai/resources/beta/threads/messages/messages';
import { Handler, APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';

// make sure process.env['OPENAI_API_KEY'] is set
const  assistantId = process.env['OPENAI_ASSISTANT_ID'];
const  correctPassword = process.env['JURIS_DATUM_PASSWORD'];

export const handler: Handler<APIGatewayProxyEventV2, APIGatewayProxyResultV2> = async (event, context) => {
    const method = event.requestContext.http.method;
    console.debug('method', method);
    if (method === 'POST')
        return post(event);
    if (method === 'GET')
        return get(event);
    return { statusCode: 405, headers: { 'Allow': 'POST, GET' } };
};

async function post(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> {
    event.queryStringParameters ??= {};
    const password = event.queryStringParameters['password'];
    if (!password)
        return { statusCode: 400 };
    if (password !== correctPassword)
        return { statusCode: 403 };
    if (!event.body)
        return { statusCode: 400 };
    const response = await start(event.body);
	return {
		statusCode: 202,
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(response)
	};
}

async function get(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> {
    event.queryStringParameters ??= {};
    const password = event.queryStringParameters['password'];
    const thread = event.queryStringParameters['thread'];
    const run = event.queryStringParameters['run'];
    console.debug('password', password);
    console.debug('thread', thread);
    console.debug('run', run);
    if (!password)
        return { statusCode: 400 };
    if (password !== correctPassword)
        return { statusCode: 403 };
    if (!thread)
        return { statusCode: 400 };
    if (!run)
        return { statusCode: 400 };
    const status = await check( thread, run );
    if (status === 'queued' || status === 'in_progress')
        return {
            statusCode: 204,
            headers: { 'Content-Type': 'application/json' },
            body: `{"status":"${status}"}\n`
        };
    if (status !== 'completed')
        return {
            statusCode: 500,
            headers: { 'Content-Type': 'application/json' },
            body: `{"status":"${status}"}\n`
        };
    const page = await retrieve( thread );
    const messages = page.data.filter(m => m.role === 'assistant');
    const content = messages[0].content[0] as MessageContentText;
	return {
		statusCode: 200,
		headers: { 'Content-Type': 'application/json' },
		body: content.text.value
	};
}

const openai = new OpenAI();

export async function start(provision: string): Promise<{ thread: string, run: string }> {
    const thread = await openai.beta.threads.create({ messages: [ { role: 'user', content: provision } ] });
    let run = await openai.beta.threads.runs.create( thread.id, { assistant_id: assistantId } );
    return { thread: thread.id, run: run.id };
}

export type Status = 'queued' | 'in_progress' | 'requires_action' | 'cancelling' | 'cancelled' | 'failed' | 'completed' | 'expired';

export async function check(thread: string, run: string): Promise<Status> {
    const rn = await openai.beta.threads.runs.retrieve( thread, run );
    return rn.status;
}

export async function retrieve(thread: string): Promise<OpenAI.Beta.Threads.Messages.ThreadMessagesPage> {
    return await openai.beta.threads.messages.list( thread );
}
