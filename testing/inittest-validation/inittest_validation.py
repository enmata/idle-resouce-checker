# !/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Class for testing API Gateway
"""
# pylint: disable=line-too-long, invalid-name, too-many-statements, missing-function-docstring

import unittest
import json
import os
import requests
import jsonschema

class inittestValidation(unittest.TestCase):
    """
    Tests all cases we have for api gateway
    """

    # defining vars
    API_BASE_URL = os.environ['API_BASE_URL']
    TEST_JSON_FILE = os.environ['TESTS_JSON_FILE']
    TESTS_RESPONSE_SCHEMA_FILE = os.environ['TESTS_RESPONSE_SCHEMA_FILE']

    # 0.x Testing <BASE_URL>/health endpoint
    def test_case(self):
        """
        Defines and runs sequencially all test defined on TEST_JSON_FILE as subTest
        """
        # Loading testevent sequence
        with open(inittestValidation.TEST_JSON_FILE, "r", encoding='utf8') as testevent_file:
            testevent_dict = json.loads(testevent_file.read())

        for testToRun in testevent_dict['ToRun']:
            with self.subTest(testToRun['testID'] + testToRun['failing_message']):
                self.validate_case(testToRun['testID'],testToRun['path'],testToRun['method'],testToRun['expected_response'],testToRun['expected_responsecode'],testToRun['failing_message'], testToRun['validation_type'])

    def validate_case(self,testID: str,path: str,method: str,expected_response: str,expected_responsecode: str,failing_message: str,validation_type: str) -> None:
        """
        Validates each individual test case, doing the required requests depending on case
        """

        # Outputting running test
        print(f"[validate_case] Checking {testID} {method} {path}")

        URL_TO_CHECK = inittestValidation.API_BASE_URL + path

        # running requests and checking response
        # response requetes scpecified on each validation_type due delete special test_case (get+delete)
        if validation_type == "json":
            response = requests.request(method,url=URL_TO_CHECK)
            self.assertEqual(response.status_code,expected_responsecode,msg=testID + "[json] Status Code - " + failing_message)
            self.assertTrue(self.validate_json(response.json()[0],inittestValidation.TESTS_RESPONSE_SCHEMA_FILE),msg=testID + "[json] Expected Response - " + failing_message)
        elif validation_type == "null":
            response = requests.request(method,url=URL_TO_CHECK)
            self.assertEqual(response.status_code,expected_responsecode,msg=testID + "[null] Status Code - " + failing_message)
            self.assertEqual(response.json(),[],msg=testID + "[null] Expected Response - " + failing_message)
        elif validation_type == "delete":
            URL_TO_CHECK_GET = URL_TO_CHECK.replace("delete","get")
            response_get = requests.get(url=URL_TO_CHECK_GET)
            payload_delete_dict = {}
            payload_delete_dict['arn'] = response_get.json()[0]['arn']
            payload_delete_dict['type'] = response_get.json()[0]['type']
            response_delete = requests.request(method,url=URL_TO_CHECK,data=json.dumps(payload_delete_dict))
            self.assertEqual(response_delete.status_code,expected_responsecode,msg=testID + "[delete] Status Code - " + failing_message)
            self.assertEqual(response_delete.json(),expected_response,msg=testID + "[delete] Expected Response - " + failing_message)
        elif validation_type == "method":
            response = requests.request(method,url=URL_TO_CHECK)
            self.assertEqual(response.status_code,expected_responsecode,msg=testID + "[method] Status Code - " + failing_message)
        else:
            response = requests.request(method,url=URL_TO_CHECK)
            self.assertEqual(response.status_code,expected_responsecode,msg=testID + "[string] Status Code - " + failing_message)
            self.assertEqual(response.json(),expected_response,msg=testID + "[string] String Expected Response - " + failing_message)


    def validate_json(self,response_json,response_schema_file) -> bool:
        """
        Validates if json response_json is valid against json schema response_schema_file
        """

        response_is_valid = bool()
        # Loading validation schema
        with open(response_schema_file, "r", encoding='utf8') as file_schema:
            response_schema_json = json.load(file_schema)

        # Trivial try/catch needed, due non boolean method on jsonvalidation class
        try:
            jsonschema.validate(response_json,response_schema_json)
            response_is_valid = True
        except:
            response_is_valid = False

        return response_is_valid
