# encoding: UTF-8
# frozen_string_literal: true

User.create(name: 'admin', password: 'admin', role: 'admin')
User.create(name: 'firstapp', password: 'foobar', role: 'application')
