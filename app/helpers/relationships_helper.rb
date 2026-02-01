module RelationshipsHelper
  def display_parent_student_relationship(parent)
    content_tag :div, class: "relationship-graph" do
      content_tag :div, class: "relationship-path" do
        safe_join([
          content_tag(:span, parent.name, class: "relationship-node"),
          content_tag(:span, "→", class: "relationship-connector")
        ] + parent.students_as_parent.map.with_index { |student, index|
          safe_join([
            content_tag(:span, student.full_name, class: "relationship-node"),
            (index < parent.students_as_parent.length - 1) ? content_tag(:span, "•", class: "relationship-connector") : nil
          ]).html_safe
        }.compact)
      end
    end
  end

  def display_teacher_classroom_relationship(teacher)
    content_tag :div, class: "relationship-graph" do
      content_tag :div, class: "relationship-path" do
        safe_join([
          content_tag(:span, teacher.name, class: "relationship-node"),
          content_tag(:span, "→", class: "relationship-connector")
        ] + teacher.classrooms_taught.map.with_index { |classroom, index|
          safe_join([
            content_tag(:span, classroom.name, class: "relationship-node"),
            (index < teacher.classrooms_taught.length - 1) ? content_tag(:span, "•", class: "relationship-connector") : nil
          ]).html_safe
        }.compact)
      end
    end
  end

  def display_classroom_student_relationship(classroom)
    content_tag :div, class: "relationship-graph" do
      content_tag :div, class: "relationship-path" do
        safe_join([
          content_tag(:span, classroom.name, class: "relationship-node"),
          content_tag(:span, "→", class: "relationship-connector")
        ] + classroom.students.map.with_index { |student, index|
          safe_join([
            content_tag(:span, student.full_name, class: "relationship-node"),
            (index < classroom.students.length - 1) ? content_tag(:span, "•", class: "relationship-connector") : nil
          ]).html_safe
        }.compact)
      end
    end
  end

  def display_student_teacher_relationship(student)
    content_tag :div, class: "relationship-graph" do
      content_tag :div, class: "relationship-path" do
        elements = [
          content_tag(:span, student.full_name, class: "relationship-node"),
          content_tag(:span, "→", class: "relationship-connector")
        ]
        
        if student.classroom&.teacher
          elements << content_tag(:span, student.classroom.teacher.name, class: "relationship-node")
        else
          elements << content_tag(:span, "No Teacher Assigned", class: "relationship-node text-red-500")
        end
        
        safe_join(elements)
      end
    end
  end

  def display_relationship_graph(title, nodes, connectors = nil)
    content_tag :div, class: "relationship-graph" do
      safe_join([
        content_tag(:h4, title, class: "text-sm font-medium mb-2"),
        content_tag(:div, class: "relationship-path") do
          safe_join(nodes.flat_map.with_index { |node, index|
            result = [content_tag(:span, node[:name], class: "relationship-node #{node[:class]}")]
            if index < nodes.length - 1
              connector = connectors&.[](index) || "→"
              result << content_tag(:span, connector, class: "relationship-connector")
            end
            result
          })
        end
      ])
    end
  end
end