# frozen_string_literal: true

require 'rails_helper'

describe 'Routing', type: :routing do
  it do
    expect(subject).to route(:get, '/users/:id').to(
      controller: :users, action: :show, id: ':id'
    )
  end

  it do
    expect(subject).to route(:get, '/users').to(
      controller: :users, action: :index
    )
  end

  it do
    expect(subject).to route(:get, '/users/:id/edit').to(
      controller: :users, action: :edit, id: ':id'
    )
  end

  it do
    expect(subject).to route(:put, '/users/:id').to(
      controller: :users, action: :update, id: ':id'
    )
  end

  it do
    expect(subject).to route(:delete, '/users/:id').to(
      controller: :users, action: :destroy, id: ':id'
    )
  end
end
