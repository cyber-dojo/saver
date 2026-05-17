require_relative 'test_base'

class KataForkTest < TestBase

  versions_test 'c5C760', %w(
  | bad id raises
  ) do
    assert_raises { kata_fork(id58, -1) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'c5C761', %w(
  | bad_index raises
  ) do
    in_kata do |id|
      assert_raises { kata_fork(id, 1) }
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'c5C762', %w[
  | fork returns id of new kata
  | whose manifest and files match the kata forked from
  | and whose version is always 2
  ] do
    in_kata do |kid|
      files = {
        "cyber-dojo.sh" => {
          "content" => "chmod 700 *.sh\n./test_*.sh\n"
        },
        "readme.txt" => {
          "content" => "Your task is to create..."
        }
      }
      stdout = {
        "content" => "1..1\nnot ok",
        "truncated" => false
      }
      stderr = {
        "content" => "",
        "truncated" => false
      }
      status = "1"
      red_summary = {
        "colour" => "red",
        "duration" => 1.46448,
        "predicted" => "none",
      }
      kata_ran_tests(kid, index=1, files, stdout, stderr, status, red_summary)

      fid = kata_fork(kid, index)

      assert kata_exists?(fid), "assert kata_exists?(#{fid})"

      original_manifest = kata_manifest(kid)
      %w( id created version visible_files ).each do |key|
        original_manifest.delete(key)
      end

      forked_manifest = kata_manifest(fid)
      forked_manifest.delete('id')
      forked_manifest.delete('created')
      version = forked_manifest.delete('version')
      assert_equal 2, version

      assert_equal original_manifest, forked_manifest, :manifests

      original_files = kata_event(kid,index)['files']
      forked_files = kata_event(fid, 0)['files']
      assert_equal original_files, forked_files, :starting_files
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'c5C763', %w[
  | fork from kata in a group
  | leaves no trace of the original group
  ] do
    in_group do |gid|
      in_kata(gid) do |kid|
        fid = kata_fork(kid, 0)
        assert kata_exists?(fid), "assert kata_exists?(#{fid})"
        forked_manifest = kata_manifest(fid)
        keys = forked_manifest.keys
        refute keys.include?('group_id')
        refute keys.include?('group_index')
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test 'c5C764', %w[
  | fork from pre-existing v0/v1 kata
  | returns id of new v2 kata whose manifest and files match source
  ] do
    id = version == 0 ? V0_KATA_ID : V1_KATA_ID
    index = kata_events(id).last['index']

    fid = kata_fork(id, index)
    assert kata_exists?(fid), "assert kata_exists?(#{fid})"

    original_manifest = kata_manifest(id)
    %w( id created version visible_files group_id group_index ).each do |key|
      original_manifest.delete(key)
    end

    forked_manifest = kata_manifest(fid)
    forked_manifest.delete('id')
    forked_manifest.delete('created')
    forked_version = forked_manifest.delete('version')
    assert_equal 2, forked_version

    assert_equal original_manifest, forked_manifest, :manifests

    original_files = kata_event(id, index)['files']
    forked_files = kata_event(fid, 0)['files']
    assert_equal original_files, forked_files, :starting_files
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test 'c5C765', %w[
  | fork from pre-existing v0/v1 kata in a group
  | leaves no trace of the original group in the forked kata
  ] do
    id = version == 0 ? V0_KATA_ID : V1_KATA_ID
    fid = kata_fork(id, 0)
    assert kata_exists?(fid), "assert kata_exists?(#{fid})"
    forked_manifest = kata_manifest(fid)
    keys = forked_manifest.keys
    refute keys.include?('group_id')
    refute keys.include?('group_index')
  end
end
