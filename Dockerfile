FROM public.ecr.aws/lambda/python:3.12

COPY pyproject.toml poetry.lock ${LAMBDA_TASK_ROOT}/

WORKDIR ${LAMBDA_TASK_ROOT}

RUN pip install --no-cache-dir poetry==2.1.3 &&\
    poetry config virtualenvs.create false &&\ 
    poetry install --only main --no-root

COPY src ${LAMBDA_TASK_ROOT}/src/

HEALTHCHECK NONE

CMD ["src.main.handler"]