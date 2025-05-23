# Ansible

## profile
Add this to the ansible.cfg to add detailed profilling and list the time it took on each task.
```cfg
callbacks_enabled = ansible.posix.profile_tasks
```

## retry count with multiple tasks/block

```ansible
---
- name: group of tasks to repeat until success
  block:
    - name: increment attempts counter
      ansible.builtin.set_fact:
        attempt_number: "{{ attempt_number | d(0) | int + 1 }}"

    - name: dummy task
      ansible.builtin.debug:
        msg: "I'm a dummy task"

    - name: task to check for success.
      # Just for the example. Will return success on attempt number 3
      ansible.builtin.command: "[ {{ attempt_number | int }} -eq 3 ]"
      changed_when: false

  rescue:
    - name: "Fail if we reached the max of {{ max_attempts | d(3) }} attempts"
      # Default will be 3 attempts if max_attempts is not passed as a parameter
      ansible.builtin.fail:
        msg: Maximum number of attempts reached
      when: attempt_number | int == max_attempts | int | d(3)

    - ansible.builtin.debug:
        msg: "group of tasks failed on attempt {{ attempt_number }}. Retrying"

    - name: add delay if needed
      # no delay if retry_delay is not passed as parameter
      ansible.builtin.wait_for:
        timeout: "{{ retry_delay | int | d(omit) }}"
      when: retry_delay is defined

    # include ourselves to retry.
    - ansible.builtin.include_tasks: task_file.yml
```

From: https://stackoverflow.com/questions/74728404/looping-or-repeating-a-group-of-tasks-until-success
