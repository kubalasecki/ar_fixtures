require File.dirname(__FILE__) + '/test_helper'
require 'fileutils'

require 'beer'
require 'drunkard'
require 'glass'

# TODO Test limit params
# TODO Test renaming
# TODO Examine contents of fixture and skeleton dump
class ArFixturesTest < Test::Unit::TestCase
  fixtures :beers, :drunkards, :beers_drunkards, :glasses
  include FileUtils

  def setup
    %w(db test/fixtures).each { |dir| mkdir_p File.join(Rails.root, dir) }
  end
  
  def test_dump_to_file
    %w(pilsner tripel).each {|name| Beer.create(:name => name) }
    
    assert_equal 2, Beer.count
    Beer.dump_to_file
    assert File.exist?(File.join(Rails.root, 'db', 'beers.yml'))
    
    Beer.destroy_all
    assert_equal 0, Beer.count
    Beer.load_from_file
    assert_equal 2, Beer.count, "#{Beer.find(:all).to_yaml}"
  end

  def test_habtm_to_file
    Beer.habtm_to_file
    assert File.exist?(File.join(Rails.root, 'db', 'beers_drunkards.yml'))
  end

  def test_load_from_file
    cp  File.join(Rails.root, 'fixtures', 'beers.yml'), 
        File.join(Rails.root, 'db', 'beers.yml')
    cp  File.join(Rails.root, 'fixtures', 'beers_drunkards.yml'), 
        File.join(Rails.root, 'db', 'beers_drunkards.yml')
    Beer.load_from_file
    assert_equal 2, Beer.count
    # assert_equal 1, Beer.find(1).drunkards.size
  end

  def test_to_fixture
    Beer.to_fixture
    assert File.exist?(File.join(Rails.root, 'test', 'fixtures', 'beers.yml'))
    assert File.exist?(File.join(Rails.root, 'test', 'fixtures', 'beers_drunkards.yml'))
  end
  
  def test_habtm_to_fixture
    Beer.habtm_to_fixture
    assert File.exist?(File.join(Rails.root, 'test', 'fixtures', 'beers_drunkards.yml'))
  end
  
  def test_to_skeleton
    Beer.to_skeleton
    assert File.exist?(File.join(Rails.root, 'test', 'fixtures', 'beers.yml'))
  end

  def test_should_use_erb
    Beer.delete_all
    
    cp  File.join(Rails.root, 'fixtures', 'beers.yml'), 
        File.join(Rails.root, 'db', 'beers.yml')
    assert_equal 0, Beer.count
    Beer.load_from_file
    assert_equal 2, Beer.count    
  end

  def teardown
    %w(db test).each { |dir| rm_rf File.join(Rails.root, dir) }    
  end
  
end
