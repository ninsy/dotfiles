from dotenv import load_dotenv
import os
import cronitor

CRONITOR_JOB_NAME='steam-deck-availability-test'

load_dotenv()

email = os.getenv("NOTIFY_EMAIL")
cronitor.api_key = os.getenv("CRONITOR_API_KEY")

cronitor.Monitor.put(
    key=CRONITOR_JOB_NAME,
    type='job',
    # TODO: pass via dotenv?
    schedule='* * * * *',
    notify=[f"email:{email}"],
    # TODO: test it! send via curl
    # assertions=[
    #     "metric.my_custom_counter > 0"
    # ],
)

# TODO: use yaml? use template string for env vars
# https://github.com/cronitorio/cronitor-python?tab=readme-ov-file#configuring-monitors

# TODO: I also need to notify when there will actually be steam deck availability change... test what will it trigger
# TODO!: use below at script that actually calls 
# @cronitor.job(CRONITOR_JOB_NAME)
# def daily_metrics_task():
#     cronitor.Monitor.ping(
#         key=CRONITOR_JOB_NAME,
#         state='run',  # or 'complete', 'fail', etc.
#         message='hello!',
#         metrics={
#             'custom_metric': 42,
#             'another_metric': 3.14
#         }
#     )

# monitor = cronitor.Monitor('important-background-job')

# # the job has started
# monitor.ping(state='run')

# # the job has completed successfully
# monitor.ping(state='complete')

# # the job has failed
# monitor.ping(state='fail')
# # optional params can be passed as keyword arguements.
# # for a complete list see https://cronitor.io/docs/telemetry-api#parameters
# monitor.ping(
#     state='run|complete|fail|ok', # run|complete|fail used to measure lifecycle of a job, ok used for manual reset only.
#     message='', # message that will be displayed in alerts as well as monitor activity panel on your dashboard.
#     metrics={
#         'duration': 100, # how long the job ran (complete|fail only). cronitor will calculate this when not provided
#         'count': 4500, # if your job is processing a number of items you can report a count
#         'error_count': 10 # the number of errors that occurred while this job was running
#     }
# )