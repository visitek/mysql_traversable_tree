DROP PROCEDURE IF EXISTS UpdateTraversable_Recursion;
CREATE PROCEDURE `UpdateTraversable_Recursion`(IN tb_name  VARCHAR(100), IN id_parent INT(10),
  INOUT                                           _left    INT(10),
  INOUT                                           _right   INT(10),
                                               IN _nesting INT(10))
  BEGIN
    DECLARE v_id INT(10);
    DECLARE v_child_count INT(10);
    DECLARE v_child_count_index INT(10) DEFAULT 0;

    DECLARE v_left INT(10);

    SET @query = CONCAT('SELECT COUNT(`id`) INTO @v_child_count FROM ', tb_name, ' WHERE `id_parent` = ', id_parent);
    PREPARE child_num FROM @query;
    EXECUTE child_num;
    DEALLOCATE PREPARE child_num;

    SET v_child_count = @v_child_count;
    IF (v_child_count IS NULL)
    THEN
      SET v_child_count = 0;
    END IF;

    SET _left = _left +1;
    SET v_left = _left;

    IF (v_child_count > 0)
    THEN
      WHILE (v_child_count > v_child_count_index) DO
        SET @query = CONCAT('SELECT `id` INTO @v_id FROM `_traversable_cursor_view` WHERE `id_parent` = ', id_parent,
                            ' LIMIT ', v_child_count_index, ' ,1');
        PREPARE child FROM @query;
        EXECUTE child;
        DEALLOCATE PREPARE child;

        SET v_id = @v_id;

        CALL UpdateTraversable_Recursion(tb_name, v_id, _left, _right, _nesting +1);

        SET _left = _left +1;
        SET _right = _right +1;

        SET v_child_count_index = v_child_count_index + 1;
      END WHILE;
    ELSE
      SET _right = _left +1;
    END IF;

    SET @query = CONCAT('UPDATE ', tb_name, ' SET `_left` = ', v_left, ', `_right` = ', _right, ', `_nesting` = ',
                        _nesting, ' WHERE `id` = ', id_parent);
    PREPARE parent_update FROM @query;
    EXECUTE parent_update;
    DEALLOCATE PREPARE parent_update;
  END;