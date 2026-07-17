require_relative 'test_base'

class GroupForkTest < TestBase

  versions_test 'D2k760', %w(
  | bad id raises
  ) do
    assert_raises { group_fork(id58, -1) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'D2k761', %w(
  | bad_index raises
  ) do
    in_kata do |id|
      assert_raises { group_fork(id, 1) }
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'D2k762', %w[
  | fork returns id of new group
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
      kata_ran_tests(kid, files, stdout, stderr, status, red_summary, laptop_id)

      index = kata_events(kid).last['index']
      fid = group_fork(kid, index)

      assert group_exists?(fid), "assert group_exists?(#{fid})"

      original_manifest = kata_manifest(kid)
      %w( id created version visible_files ).each do |key|
        original_manifest.delete(key)
      end

      forked_manifest = group_manifest(fid)
      %w( id created ).each do |key|
        forked_manifest.delete(key)
      end
      forked_files = forked_manifest.delete('visible_files')
      version = forked_manifest.delete('version')
      assert_equal 2, version

      assert_equal original_manifest, forked_manifest, :manifests

      original_files = kata_event(kid,index)['files']
      assert_equal original_files, forked_files, :starting_files
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'D2k763', %w[
  | fork from kata in a group
  | leaves no trace of the original group
  ] do
    in_group do |gid|
      in_kata(gid) do |kid|
        fid = group_fork(kid, 0)
        assert group_exists?(fid), "assert group_exists?(#{fid})"
        forked_manifest = group_manifest(fid)
        keys = forked_manifest.keys
        refute keys.include?('group_id')
        refute keys.include?('group_index')
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, 'D2k766', %w[
  | group_fork from pre-existing v0 kata
  | returns id of new v2 group whose manifest and files match source
  ] do
    id = V0_KATA_ID
    index = kata_events(id).last['index']

    fid = group_fork(id, index)
    assert group_exists?(fid), "assert group_exists?(#{fid})"

    original_manifest = kata_manifest(id)
    %w( id created version visible_files group_id group_index ).each do |key|
      original_manifest.delete(key)
    end

    forked_manifest = group_manifest(fid)
    %w( id created ).each do |key|
      forked_manifest.delete(key)
    end
    forked_files = forked_manifest.delete('visible_files')
    forked_version = forked_manifest.delete('version')
    assert_equal 2, forked_version

    assert_equal original_manifest, forked_manifest, :manifests

    original_files = kata_event(id, index)['files']
    assert_equal original_files, forked_files, :starting_files
  end

  version_test 1, 'D2k767', %w[
  | group_fork from pre-existing v1 kata
  | returns id of new v2 group whose manifest and files match source
  ] do
    id = V1_KATA_ID
    index = kata_events(id).last['index']

    fid = group_fork(id, index)
    assert group_exists?(fid), "assert group_exists?(#{fid})"

    original_manifest = kata_manifest(id)
    %w( id created version visible_files group_id group_index ).each do |key|
      original_manifest.delete(key)
    end

    forked_manifest = group_manifest(fid)
    %w( id created ).each do |key|
      forked_manifest.delete(key)
    end
    forked_files = forked_manifest.delete('visible_files')
    forked_version = forked_manifest.delete('version')
    assert_equal 2, forked_version

    assert_equal original_manifest, forked_manifest, :manifests

    original_files = kata_event(id, index)['files']
    assert_equal original_files, forked_files, :starting_files
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, 'D2k768', %w[
  | group_fork from pre-existing v0 kata in a group
  | leaves no trace of the original group in the forked group
  ] do
    id = V0_KATA_ID
    fid = group_fork(id, 0)
    assert group_exists?(fid), "assert group_exists?(#{fid})"
    forked_manifest = group_manifest(fid)
    keys = forked_manifest.keys
    refute keys.include?('group_id')
    refute keys.include?('group_index')
  end

  version_test 1, 'D2k769', %w[
  | group_fork from pre-existing v1 kata in a group
  | leaves no trace of the original group in the forked group
  ] do
    id = V1_KATA_ID
    fid = group_fork(id, 0)
    assert group_exists?(fid), "assert group_exists?(#{fid})"
    forked_manifest = group_manifest(fid)
    keys = forked_manifest.keys
    refute keys.include?('group_id')
    refute keys.include?('group_index')
  end

end
