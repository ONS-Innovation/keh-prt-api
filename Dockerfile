FROM public.ecr.aws/lambda/python:3.12

COPY poetry.lock pyproject.toml ${LAMBDA_TASK_ROOT}/
COPY src ${LAMBDA_TASK_ROOT}/src/

WORKDIR ${LAMBDA_TASK_ROOT}

RUN pip install --upgrade pip
RUN pip install poetry

RUN poetry config virtualenvs.create false
RUN poetry install --no-root

HEALTHCHECK NONE

CMD ["src.main.handler"]