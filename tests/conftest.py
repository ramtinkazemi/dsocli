import pytest
import boto3

@pytest.fixture(autouse=True)
def disable_boto_session(monkeypatch):
    def stunted_access():
        raise RuntimeError("AWS access not allowed during testing!")
    monkeypatch.setattr(boto3.session, "Session", lambda *args, **kwargs: stunted_access())
    monkeypatch.setattr(boto3, "client", lambda *args, **kwargs: stunted_access())
    monkeypatch.setattr(boto3, "resource", lambda *args, **kwargs: stunted_access())


@pytest.fixture
def parameters_key_value_shell():
    return [
            "param1='value_for_param1'",
            'param2="value_for_param2"',
            'param3=value_for_param3',
            "scope.param1='value_for_scope.param1'",
            'scope.param2="value_for_scope.param1"',
            "scope1.param3=value_for_scope1.param3",
            'scope1.scope2.param1="value_for_scope1.scope2.param1"',
            "scope1.scope2.param2='value_for_scope1.scope2.param1'",
            "scope1.scope2.param2=value_for_scope1.scope2.param1",
    ]
