/*******************************************************************************
* Copyright 2019 Amazon.com, Inc. and its affiliates. All Rights Reserved.
*
* Licensed under the Amazon Software License (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*   http://aws.amazon.com/asl/
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*
********************************************************************************/
let expect = require('chai').expect;
var path = require('path');
let AWS = require('aws-sdk-mock');
AWS.setSDK(path.resolve('./node_modules/aws-sdk'));

let lambda = require('../index.js');

describe('#DYNAMODB UPDATE::', () => {
	let _event = {
		guid: "SUCCESS",
		hello: "from AWS mock"
	};

	process.env.ErrorHandler = 'error_handler';

	afterEach(() => {
		AWS.restore('DynamoDB.DocumentClient');
	});

	it('should return "SUCCESS" when db put returns success', async () => {
		AWS.mock('DynamoDB.DocumentClient', 'update', Promise.resolve());

		let response = await lambda.handler(_event)
		expect(response.guid).to.equal('SUCCESS');
	});

	it('should return "DB ERROR" when db put fails', async () => {
		AWS.mock('DynamoDB.DocumentClient', 'update', Promise.reject('DB ERROR'));
		AWS.mock('Lambda','invoke', Promise.resolve());

		await lambda.handler(_event).catch(err => {
			expect(err).to.equal('DB ERROR');
		});
	});

	it('should return "DB ERROR" when db put fails', async () => {
		AWS.mock('DynamoDB.DocumentClient', 'update', Promise.reject('DB ERROR'));
		AWS.mock('Lambda','invoke', Promise.reject('LAMBDA ERROR'));

		await lambda.handler(_event).catch(err => {
			expect(err).to.equal('DB ERROR');
		});
	});

});
