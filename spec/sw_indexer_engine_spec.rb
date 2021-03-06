require 'rails_helper'

describe SwIndexerEngine do
  include XmlFixtures
  let(:smods_rec) { Stanford::Mods::Record.new }
  let(:item_pid) { 'druid:zz999zz9999' }
  before :each do
    @dor_services_stub = dor_services_stub
    @delete_solr_stub = delete_stub_solr
    @post_solr_stub = post_stub_solr
    stub_collection('oo000oo0000', coll_image_xml)
  end

  describe 'setup' do
    it 'can inititalize the correct class name and read settings correctly' do
      expect(BaseIndexer.mapper_class_name.constantize).to eq SwMapper
      expect(Settings.PURL_URL).to eq 'https://purl.stanford.edu'
      expect(Settings.SOLR_TARGETS.to_hash.deep_stringify_keys).to eq({"MYSOLR" => {"url"=>"http://solr-cloud/mysolr"},"SEARCHWORKSPREVIEW" => {"url"=>"http://solr-cloud/searchworkspreview"}})
    end
  end

  describe 'index' do
    context 'for targets that should be checked for catkeys' do
      # NOTE: The MYSOLR target has catkey checks applied
      let(:catkey_check_target) { 'MYSOLR' }
      it 'indexes and does not call solr delete nor dor-services 856 generation call for a record with no catkey' do
        stub_purl(item_pid, item_image_xml, item_image_mods)
        subject.index(item_pid, catkey_check_target => true)
        expect(@delete_solr_stub).not_to have_been_requested
        expect(@dor_services_stub).not_to have_been_requested
        expect(@post_solr_stub).to have_been_requested.once
      end
      it 'indexes and calls dor-services 856 generation call for a record with no catkey but with previous catkeys' do
        stub_purl(item_pid, item_image_xml_previous_catkeys, item_image_mods)
        subject.index(item_pid, catkey_check_target => true)
        expect(@delete_solr_stub).not_to have_been_requested
        expect(@dor_services_stub).to have_been_requested.once
        expect(@post_solr_stub).to have_been_requested.once
      end
      it 'does not index but instead calls solr delete and calls dor-services 856 generation call for a record with a catkey' do
        stub_purl(item_pid, item_image_xml_with_catkey, item_image_mods)
        subject.index(item_pid, catkey_check_target => true)
        expect(@delete_solr_stub).to have_been_requested.once
        expect(@dor_services_stub).to have_been_requested.once
        expect(@post_solr_stub).not_to have_been_requested
      end
      it 'does not index but instead calls solr delete and calls dor-services 856 generation call for a record with both previous and current catkeys' do
        stub_purl(item_pid, item_image_xml_previous_and_current_catkey, item_image_mods)
        subject.index(item_pid, catkey_check_target => true)
        expect(@delete_solr_stub).to have_been_requested.once
        expect(@dor_services_stub).to have_been_requested.once
        expect(@post_solr_stub).not_to have_been_requested
      end
    end
    context 'for targets that should NOT be checked for catkeys' do
      # NOTE: The SEARCHWORKSPREVIEW target is configured to skip all catkey checks
      let(:no_catkey_check_target) { 'SEARCHWORKSPREVIEW' }
      it 'indexes and does not call solr delete nor dor-services 856 generation call for a record even with a catkey' do
        stub_purl(item_pid, item_image_xml_with_catkey, item_image_mods)
        expect(subject).not_to receive(:purl)
        subject.index(item_pid, no_catkey_check_target => true)
        expect(@delete_solr_stub).not_to have_been_requested
        expect(@dor_services_stub).not_to have_been_requested
        expect(@post_solr_stub).to have_been_requested.once
      end
      it 'indexes and does not call solr delete nor dor-services 856 generation call for a record with no catkey' do
        stub_purl(item_pid, item_image_xml, item_image_mods)
        expect(subject).not_to receive(:purl)
        subject.index(item_pid, no_catkey_check_target => true)
        expect(@delete_solr_stub).not_to have_been_requested
        expect(@dor_services_stub).not_to have_been_requested
        expect(@post_solr_stub).to have_been_requested.once
      end
    end
    context 'for a non-configured target' do
      # NOTE: The BOGUS target is not configured in test.yml
      let(:bogus_target) { 'BOGUS' }
      it 'does not index and does not call solr delete nor dor-services 856 generation call for a record with no catkey' do
        stub_purl(item_pid, item_image_xml, item_image_mods)
        subject.index(item_pid, bogus_target => true)
        expect(@delete_solr_stub).not_to have_been_requested
        expect(@dor_services_stub).not_to have_been_requested
        expect(@post_solr_stub).not_to have_been_requested
      end
    end
  end
end
