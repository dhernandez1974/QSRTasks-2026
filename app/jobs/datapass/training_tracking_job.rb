class Datapass::TrainingTrackingJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    data['Restaurant']['Employees'].each do |student|
      if student['GEID'] == 'VDSDEFAULT'
        tracking = Datapass::TrainingTracking.find_by(mdmid: student['MDMID'].downcase.strip)
        old_geid = tracking.geid.downcase.strip unless tracking.nil?
        existing_classes = tracking.courses unless tracking.nil?
        new_classes = course_list(student['Courses'], data['Courses'])
        unless tracking.nil?
          new_classes = new_classes << existing_classes
          new_classes = new_classes.flatten.uniq
        end
        tracking.update(geid: old_geid, courses: new_classes, mdmid: student['MDMID'].downcase.strip) unless tracking.nil?
      else
        tracking = Datapass::TrainingTracking.find_by(geid: student['GEID'].downcase.strip)
        existing_classes = tracking.courses unless tracking.nil?
        new_classes = course_list(student['Courses'], data['Courses'])
        unless existing_classes.nil?
          new_classes = new_classes << existing_classes
          new_classes = new_classes.flatten.uniq
        end
        if tracking.nil?
          Datapass::TrainingTracking.create(geid: student['GEID'].downcase.strip, courses: new_classes, mdmid: student['MDMID'].downcase.strip)
        else
          tracking.update(geid: student['GEID'].downcase.strip, courses: new_classes, mdmid: student['MDMID'].downcase.strip)
        end
      end
    end
  end

  def course_list(courses, course_listing)
    course_list = []
    courses.each do |course|
      klass = Datapass::CampusCourse.find_by(course_id: course['CourseID'])
      if klass.nil?
        course_list << add_course(course['CourseID'], course_listing)
      else
        course_list << klass.id
      end
    end
    course_list
  end

  def add_course(course_id, course_listing)
    course_listing.each do |c|
      if c['CourseId'] == course_id
        new_course = Datapass::CampusCourse.create(course_id: course_id, course_title: c['CourseTitle'])
        return new_course.id
      end
    end
  end

end
