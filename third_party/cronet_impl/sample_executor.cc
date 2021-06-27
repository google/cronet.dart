// Derived from Chromium sample.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "sample_executor.h"
#include "../../src/wrapper.h"
#include <iostream>

/* Executor Only */

Cronet_ExecutorPtr (*_Cronet_Executor_CreateWith)(Cronet_Executor_ExecuteFunc);
void (*_Cronet_Executor_SetClientContext)(
    Cronet_ExecutorPtr self,
    Cronet_ClientContext client_context);
Cronet_ClientContext (*_Cronet_Executor_GetClientContext)(Cronet_ExecutorPtr self);
void (*_Cronet_Executor_Destroy)(Cronet_ExecutorPtr self);
void (*_Cronet_Runnable_Run)(Cronet_RunnablePtr self);
void (*_Cronet_Runnable_Destroy)(Cronet_RunnablePtr self);

void InitCronetExecutorApi(void *executor_createWith, void *executor_setClientContext,
  void *executor_getClientContext,
  void *executor_destroy,
  void *runnable_run,
  void *runnable_destroy) {
    _Cronet_Executor_CreateWith = reinterpret_cast<Cronet_ExecutorPtr (*)(Cronet_Executor_ExecuteFunc)>(executor_createWith);
    _Cronet_Executor_SetClientContext = reinterpret_cast<void (*)(Cronet_ExecutorPtr, Cronet_ClientContext)>
                                        (executor_setClientContext);
    _Cronet_Executor_GetClientContext = reinterpret_cast<Cronet_ClientContext (*)(Cronet_ExecutorPtr)>
                                        (executor_getClientContext);
    _Cronet_Executor_Destroy = reinterpret_cast<void (*)(Cronet_ExecutorPtr)>(executor_destroy);
    _Cronet_Runnable_Run = reinterpret_cast<void (*)(Cronet_RunnablePtr)>(runnable_run);
    _Cronet_Runnable_Destroy = reinterpret_cast<void (*)(Cronet_RunnablePtr)>(runnable_destroy);
}
// IMPORT(Cronet_ExecutorPtr, Cronet_Executor_CreateWith, Cronet_Executor_ExecuteFunc);
// IMPORT(void, Cronet_Executor_SetClientContext, Cronet_ExecutorPtr, Cronet_ClientContext);
// IMPORT(void, Cronet_Executor_Destroy, Cronet_ExecutorPtr);
// IMPORT(void, Cronet_Runnable_Run, Cronet_RunnablePtr);
// IMPORT(void, Cronet_Runnable_Destroy, Cronet_RunnablePtr);
// IMPORT(Cronet_ClientContext, Cronet_Executor_GetClientContext, Cronet_ExecutorPtr);

SampleExecutor::SampleExecutor()
    : executor_thread_(SampleExecutor::ThreadLoop, this) {}
SampleExecutor::~SampleExecutor() {
  ShutdownExecutor();
  _Cronet_Executor_Destroy(executor_);
}

void SampleExecutor::Init() {
  executor_ = _Cronet_Executor_CreateWith(SampleExecutor::Execute);
  _Cronet_Executor_SetClientContext(executor_, this);
}

Cronet_ExecutorPtr SampleExecutor::GetExecutor() {
  return executor_;
}
void SampleExecutor::ShutdownExecutor() {
  // Break tasks loop.
  {
    std::lock_guard<std::mutex> lock(lock_);
    stop_thread_loop_ = true;
  }
  task_available_.notify_one();
  // Wait for executor thread.
  executor_thread_.join();
}
void SampleExecutor::RunTasksInQueue() {
  // Process runnables in |task_queue_|.
  while (true) {
    Cronet_RunnablePtr runnable = nullptr;
    {
      
      // Wait for a task to run or stop signal.
      std::unique_lock<std::mutex> lock(lock_);
      while (task_queue_.empty() && !stop_thread_loop_) {
        task_available_.wait(lock);
      }
      if (stop_thread_loop_) {
        break;
      }
      if (task_queue_.empty()) {
        continue;
      }
      runnable = task_queue_.front();
      task_queue_.pop();
      
    }
    _Cronet_Runnable_Run(runnable);
    _Cronet_Runnable_Destroy(runnable);
  }
  // Delete remaining tasks.
  std::queue<Cronet_RunnablePtr> tasks_to_destroy;
  {
    std::unique_lock<std::mutex> lock(lock_);
    tasks_to_destroy.swap(task_queue_);
  }
  while (!tasks_to_destroy.empty()) {
    _Cronet_Runnable_Destroy(tasks_to_destroy.front());
    tasks_to_destroy.pop();
  }
}
/* static */
void SampleExecutor::ThreadLoop(SampleExecutor* executor) {
  executor->RunTasksInQueue();
}
void SampleExecutor::Execute(Cronet_RunnablePtr runnable) {
  {
    std::lock_guard<std::mutex> lock(lock_);
    if (!stop_thread_loop_) {
      task_queue_.push(runnable);
      runnable = nullptr;
    }
  }
  if (runnable) {
    _Cronet_Runnable_Destroy(runnable);
  } else {
    task_available_.notify_one();
  }
}
/* static */
void SampleExecutor::Execute(Cronet_ExecutorPtr self,
                             Cronet_RunnablePtr runnable) {
  auto* executor =
      static_cast<SampleExecutor*>(_Cronet_Executor_GetClientContext(self));
  executor->Execute(runnable);
}
